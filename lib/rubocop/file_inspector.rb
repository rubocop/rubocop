# encoding: utf-8

module Rubocop
  # This class handles the processing of files, which includes dealing with
  # formatters and letting cops inspect the files.
  class FileInspector
    def initialize(options)
      @options = options
      @errors = []
    end

    # Takes a block which it calls once per inspected file.  The block shall
    # return true if the caller wants to break the loop early.
    def process_files(target_files, config_store)
      target_files.each(&:freeze).freeze
      inspected_files = []
      any_failed = false

      formatter_set.started(target_files)

      target_files.each do |file|
        break if yield
        offences = process_file(file, config_store)

        any_failed = true unless offences.empty?
        inspected_files << file
      end

      formatter_set.finished(inspected_files.freeze)
      formatter_set.close_output_files
      any_failed
    end

    def display_error_summary
      return if @errors.empty?
      plural = @errors.count > 1 ? 's' : ''
      warn "\n#{@errors.count} error#{plural} occurred:".color(:red)
      @errors.each { |error| warn error }
      warn 'Errors are usually caused by RuboCop bugs.'
      warn 'Please, report your problems to RuboCop\'s issue tracker.'
      warn 'Mention the following information in the issue report:'
      warn Rubocop::Version.version(true)
    end

    private

    def process_file(file, config_store)
      puts "Scanning #{file}" if @options[:debug]
      offences = []
      formatter_set.file_started(file, {})

      # When running with --auto-correct, we need to inspect the file (which
      # includes writing a corrected version of it) until no more corrections
      # are made. This is because automatic corrections can introduce new
      # offences. In the normal case the loop is only executed once.
      loop do
        new_offences = inspect_file(file, config_store)
        unique_new = new_offences.reject { |n| offences.include?(n) }

        offences += unique_new
        break unless unique_new.any?(&:corrected?)
      end

      formatter_set.file_finished(file, offences.freeze)
      offences
    end

    def inspect_file(file, config_store)
      config = config_store.for(file)
      team = Cop::Team.new(mobilized_cop_classes(config), config, @options)
      offences = team.inspect_file(file)
      @errors.concat(team.errors)
      offences
    end

    def mobilized_cop_classes(config)
      @mobilized_cop_classes ||= {}
      @mobilized_cop_classes[config.object_id] ||= begin
        cop_classes = Cop::Cop.all

        if @options[:only]
          cop_classes.select! { |c| c.cop_name == @options[:only] }
        else
          # filter out Rails cops unless requested
          cop_classes.reject!(&:rails?) unless run_rails_cops?(config)

          # filter out style cops when --lint is passed
          cop_classes.select!(&:lint?) if @options[:lint]
        end

        cop_classes
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
  end
end
