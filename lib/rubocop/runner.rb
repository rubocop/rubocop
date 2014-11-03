# encoding: utf-8

module RuboCop
  # This class handles the processing of files, which includes dealing with
  # formatters and letting cops inspect the files.
  class Runner
    attr_reader :errors, :aborting
    alias_method :aborting?, :aborting

    def initialize(options, config_store)
      @options = options
      @config_store = config_store
      @errors = []
      @aborting = false
    end

    def run(paths)
      target_files = find_target_files(paths)

      inspected_files = []
      all_passed = true

      formatter_set.started(target_files)

      target_files.each do |file|
        break if aborting?
        offenses = process_file(file)
        all_passed = false if offenses.any? { |o| considered_failure?(o) }
        inspected_files << file
        break if @options[:fail_fast] && !all_passed
      end

      formatter_set.finished(inspected_files.freeze)
      formatter_set.close_output_files

      all_passed
    end

    def abort
      @aborting = true
    end

    private

    def find_target_files(paths)
      target_finder = TargetFinder.new(@config_store, @options)
      target_files = target_finder.find(paths)
      target_files.each(&:freeze).freeze
    end

    def process_file(file)
      puts "Scanning #{file}" if @options[:debug]

      processed_source = ProcessedSource.from_file(file)

      formatter_set.file_started(file, file_info(processed_source))

      offenses = do_inspection_loop(file, processed_source)

      formatter_set.file_finished(file, offenses.compact.sort.freeze)
      offenses
    end

    def do_inspection_loop(file, processed_source)
      offenses = []

      # When running with --auto-correct, we need to inspect the file (which
      # includes writing a corrected version of it) until no more corrections
      # are made. This is because automatic corrections can introduce new
      # offenses. In the normal case the loop is only executed once.
      loop do
        # The offenses that couldn't be corrected will be found again so we
        # only keep the corrected ones in order to avoid duplicate reporting.
        offenses.select!(&:corrected?)

        new_offenses, updated_source_file = inspect_file(processed_source)
        offenses.concat(new_offenses).uniq!
        break unless updated_source_file

        # We have to reprocess the source to pickup the changes. Since the
        # change could (theoretically) introduce parsing errors, we break the
        # loop if we find any.
        processed_source = ProcessedSource.from_file(file)
      end

      offenses
    end

    def inspect_file(processed_source)
      config = @config_store.for(processed_source.path)
      team = Cop::Team.new(mobilized_cop_classes(config), config, @options)
      offenses = team.inspect_file(processed_source)
      @errors.concat(team.errors)
      [offenses, team.updated_source_file?]
    end

    def mobilized_cop_classes(config)
      @mobilized_cop_classes ||= {}
      @mobilized_cop_classes[config.object_id] ||= begin
        cop_classes = Cop::Cop.all

        if @options[:only]
          validate_only_option

          cop_classes.select! do |c|
            @options[:only].include?(c.cop_name) || @options[:lint] && c.lint?
          end
        else
          # filter out Rails cops unless requested
          cop_classes.reject!(&:rails?) unless run_rails_cops?(config)

          # select only lint cops when --lint is passed
          cop_classes.select!(&:lint?) if @options[:lint]
        end

        cop_classes
      end
    end

    def validate_only_option
      @options[:only].each do |cop_to_run|
        next unless Cop::Cop.all.none? { |c| c.cop_name == cop_to_run }
        fail ArgumentError, "Unrecognized cop name: #{cop_to_run}."
      end
    end

    def run_rails_cops?(config)
      @options[:rails] || config['AllCops']['RunRailsCops']
    end

    def formatter_set
      @formatter_set ||= begin
        set = Formatter::FormatterSet.new
        pairs = @options[:formatters] || [[Options::DEFAULT_FORMATTER]]
        pairs.each do |formatter_key, output_path|
          set.add_formatter(formatter_key, output_path)
        end
        set
      rescue => error
        warn error.message
        $stderr.puts error.backtrace
        exit(1)
      end
    end

    def considered_failure?(offense)
      offense.severity >= minimum_severity_to_fail
    end

    def minimum_severity_to_fail
      @minimum_severity_to_fail ||= begin
        name = @options[:fail_level] || :refactor
        RuboCop::Cop::Severity.new(name)
      end
    end

    def file_info(processed_source)
      { cop_disabled_line_ranges: processed_source.disabled_line_ranges }
    end
  end
end
