# frozen_string_literal: true

require 'parallel'

module RuboCop
  # This class handles the processing of files, which includes dealing with
  # formatters and letting cops inspect the files.
  class Runner # rubocop:disable Metrics/ClassLength
    # An exception indicating that the inspection loop got stuck correcting
    # offenses back and forth.
    class InfiniteCorrectionLoop < RuntimeError
      attr_reader :offenses

      def initialize(path, offenses)
        super "Infinite loop detected in #{path}."
        @offenses = offenses
      end
    end

    MAX_ITERATIONS = 200

    attr_reader :errors, :warnings
    attr_writer :aborting

    def initialize(options, config_store)
      @options = options
      @config_store = config_store
      @errors = []
      @warnings = []
      @aborting = false
    end

    def run(paths)
      target_files = find_target_files(paths)
      if @options[:list_target_files]
        list_files(target_files)
      else
        warm_cache(target_files) if @options[:parallel]
        inspect_files(target_files)
      end
    rescue Interrupt
      self.aborting = true
      warn ''
      warn 'Exiting...'

      false
    end

    def aborting?
      @aborting
    end

    private

    # Warms up the RuboCop cache by forking a suitable number of rubocop
    # instances that each inspects its allotted group of files.
    def warm_cache(target_files)
      puts 'Running parallel inspection' if @options[:debug]
      Parallel.each(target_files, &method(:file_offenses))
    end

    def find_target_files(paths)
      target_finder = TargetFinder.new(@config_store, @options)
      target_files = target_finder.find(paths)
      target_files.each(&:freeze).freeze
    end

    def inspect_files(files)
      inspected_files = []

      formatter_set.started(files)

      each_inspected_file(files) { |file| inspected_files << file }
    ensure
      ResultCache.cleanup(@config_store, @options[:debug]) if cached_run?
      formatter_set.finished(inspected_files.freeze)
      formatter_set.close_output_files
    end

    def each_inspected_file(files)
      files.reduce(true) do |all_passed, file|
        offenses = process_file(file)
        yield file

        if offenses.any? { |o| considered_failure?(o) }
          break false if @options[:fail_fast]

          next false
        end

        all_passed
      end
    end

    def list_files(paths)
      paths.each do |path|
        puts PathUtil.relative_path(path)
      end
    end

    def process_file(file)
      puts "Scanning #{file}" if @options[:debug]
      file_started(file)

      offenses = file_offenses(file)
      if @options[:display_only_fail_level_offenses]
        offenses = offenses.select { |o| considered_failure?(o) }
      end
      formatter_set.file_finished(file, offenses)
      offenses
    rescue InfiniteCorrectionLoop => e
      formatter_set.file_finished(file, e.offenses.compact.sort.freeze)
      raise
    end

    def file_offenses(file)
      file_offense_cache(file) do
        source = get_processed_source(file)
        source, offenses = do_inspection_loop(file, source)
        add_unneeded_disables(file, offenses.compact.sort, source)
      end
    end

    def file_offense_cache(file)
      cache = ResultCache.new(file, @options, @config_store) if cached_run?
      if cache && cache.valid?
        offenses = cache.load
        # If we're running --auto-correct and the cache says there are
        # offenses, we need to actually inspect the file. If the cache shows no
        # offenses, we're good.
        real_run_needed = @options[:auto_correct] && offenses.any?
      else
        real_run_needed = true
      end

      if real_run_needed
        offenses = yield
        save_in_cache(cache, offenses)
      end

      offenses
    end

    def add_unneeded_disables(file, offenses, source)
      if check_for_unneeded_disables?(source)
        config = @config_store.for(file)
        if config.for_cop(Cop::Lint::UnneededCopDisableDirective)
                 .fetch('Enabled')
          cop = Cop::Lint::UnneededCopDisableDirective.new(config, @options)
          if cop.relevant_file?(file)
            cop.check(offenses, source.disabled_line_ranges, source.comments)
            offenses += cop.offenses
            autocorrect_unneeded_disables(source, cop)
          end
        end
        offenses
      end

      offenses.sort.reject(&:disabled?).freeze
    end

    def check_for_unneeded_disables?(source)
      !source.disabled_line_ranges.empty? && !filtered_run?
    end

    def filtered_run?
      @options[:except] || @options[:only]
    end

    def autocorrect_unneeded_disables(source, cop)
      cop.processed_source = source

      Cop::Team.new(
        RuboCop::Cop::Registry.new,
        nil,
        @options
      ).autocorrect(source.buffer, [cop])
    end

    def file_started(file)
      formatter_set.file_started(file,
                                 cli_options: @options,
                                 config_store: @config_store)
    end

    def cached_run?
      @cached_run ||=
        (@options[:cache] == 'true' ||
         @options[:cache] != 'false' &&
         @config_store.for(Dir.pwd).for_all_cops['UseCache']) &&
        # When running --auto-gen-config, there's some processing done in the
        # cops related to calculating the Max parameters for Metrics cops. We
        # need to do that processing and can not use caching.
        !@options[:auto_gen_config] &&
        # We can't cache results from code which is piped in to stdin
        !@options[:stdin]
    end

    def save_in_cache(cache, offenses)
      return unless cache
      # Caching results when a cop has crashed would prevent the crash in the
      # next run, since the cop would not be called then. We want crashes to
      # show up the same in each run.
      return if errors.any? || warnings.any?

      cache.save(offenses)
    end

    def do_inspection_loop(file, processed_source)
      offenses = []

      # When running with --auto-correct, we need to inspect the file (which
      # includes writing a corrected version of it) until no more corrections
      # are made. This is because automatic corrections can introduce new
      # offenses. In the normal case the loop is only executed once.
      iterate_until_no_changes(processed_source, offenses) do
        # The offenses that couldn't be corrected will be found again so we
        # only keep the corrected ones in order to avoid duplicate reporting.
        offenses.select!(&:corrected?)
        new_offenses, updated_source_file = inspect_file(processed_source)
        offenses.concat(new_offenses).uniq!

        # We have to reprocess the source to pickup the changes. Since the
        # change could (theoretically) introduce parsing errors, we break the
        # loop if we find any.
        break unless updated_source_file

        processed_source = get_processed_source(file)
      end

      [processed_source, offenses]
    end

    def iterate_until_no_changes(source, offenses)
      # Keep track of the state of the source. If a cop modifies the source
      # and another cop undoes it producing identical source we have an
      # infinite loop.
      @processed_sources = []

      # It is also possible for a cop to keep adding indefinitely to a file,
      # making it bigger and bigger. If the inspection loop runs for an
      # excessively high number of iterations, this is likely happening.
      iterations = 0

      loop do
        check_for_infinite_loop(source, offenses)

        if (iterations += 1) > MAX_ITERATIONS
          raise InfiniteCorrectionLoop.new(source.path, offenses)
        end

        source = yield
        break unless source
      end
    end

    # Check whether a run created source identical to a previous run, which
    # means that we definitely have an infinite loop.
    def check_for_infinite_loop(processed_source, offenses)
      checksum = processed_source.checksum

      if @processed_sources.include?(checksum)
        raise InfiniteCorrectionLoop.new(processed_source.path, offenses)
      end

      @processed_sources << checksum
    end

    def inspect_file(processed_source)
      config = @config_store.for(processed_source.path)
      enable_rails_cops(config) if @options[:rails]
      team = Cop::Team.new(mobilized_cop_classes(config), config, @options)
      offenses = team.inspect_file(processed_source)
      @errors.concat(team.errors)
      @warnings.concat(team.warnings)
      [offenses, team.updated_source_file?]
    end

    def enable_rails_cops(config)
      config['Rails'] ||= {}
      config['Rails']['Enabled'] = true
    end

    def mobilized_cop_classes(config)
      @mobilized_cop_classes ||= {}
      @mobilized_cop_classes[config.object_id] ||= begin
        cop_classes = Cop::Cop.all

        %i[only except].each do |opt|
          OptionsValidator.validate_cop_list(@options[opt])
        end

        if @options[:only]
          cop_classes.select! { |c| c.match?(@options[:only]) }
        else
          filter_cop_classes(cop_classes, config)
        end

        cop_classes.reject! { |c| c.match?(@options[:except]) }

        Cop::Registry.new(cop_classes)
      end
    end

    def filter_cop_classes(cop_classes, config)
      # use only cops that link to a style guide if requested
      return unless style_guide_cops_only?(config)

      cop_classes.select! { |cop| config.for_cop(cop)['StyleGuide'] }
    end

    def style_guide_cops_only?(config)
      @options[:only_guide_cops] || config.for_all_cops['StyleGuideCopsOnly']
    end

    def formatter_set
      @formatter_set ||= begin
        set = Formatter::FormatterSet.new(@options)
        pairs = @options[:formatters] || [['progress']]
        pairs.each do |formatter_key, output_path|
          set.add_formatter(formatter_key, output_path)
        end
        set
      end
    end

    def considered_failure?(offense)
      # For :autocorrect level, any offense - corrected or not - is a failure.
      return false if offense.disabled?

      return true if @options[:fail_level] == :autocorrect

      !offense.corrected? && offense.severity >= minimum_severity_to_fail
    end

    def minimum_severity_to_fail
      @minimum_severity_to_fail ||= begin
        name = @options[:fail_level] || :refactor
        RuboCop::Cop::Severity.new(name)
      end
    end

    def get_processed_source(file)
      ruby_version = @config_store.for(file).target_ruby_version

      if @options[:stdin]
        ProcessedSource.new(@options[:stdin], ruby_version, file)
      else
        ProcessedSource.from_file(file, ruby_version)
      end
    end
  end
end
