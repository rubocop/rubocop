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

    # Save cop's inspect result
    class InspectResult
      attr_accessor :offenses, :errors, :warnings

      def initialize
        @offenses = []
        @errors = []
        @warnings = []
      end
    end

    # Save inspect result and the file passed or got error to inspect
    class ProcessResult
      class << self
        def build_error_result(filepath, error)
          ProcessResult.new(filepath, nil, false, error)
        end

        def build_succeed_result(filepath, inspect_result, passed)
          ProcessResult.new(filepath, inspect_result, passed, nil)
        end
      end

      # error is error object so it's not related to InspectResult.errors
      attr_accessor :filepath, :inspect_result, :passed, :error

      def initialize(filepath, inspect_result, passed, error)
        @filepath = filepath
        @inspect_result = inspect_result
        @passed = passed
        @error = error
      end

      def error_file?
        !@error.nil?
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

    def find_target_files(paths)
      target_finder = TargetFinder.new(@config_store, @options)
      target_files = target_finder.find(paths)
      target_files.each(&:freeze).freeze
    end

    def inspect_files(files)
      formatter_set.started(files)

      conductor = build_conductor(files)
      conductor.run_inspect(&method(:process_file))

      # TODO: show first only...
      error = conductor.first_error_object
      raise error if error

      conductor.all_passed
    ensure
      inspect_finished(conductor, files)
    end

    # when error raised or Interrupt, save data
    def inspect_finished(conductor, files)
      if conductor
        @errors = conductor.errors
        @warnings = conductor.warnings
        inspected_files = conductor.inspected_files
      else
        @errors = []
        @warnings = []
        inspected_files = []
      end

      # OPTIMIZE: Calling `ResultCache.cleanup` takes time. This optimization
      # mainly targets editors that integrates RuboCop. When RuboCop is run
      # by an editor, it should be inspecting only one file.
      if files.size > 1 && cached_run?
        ResultCache.cleanup(@config_store, @options[:debug])
      end
      formatter_set.finished(inspected_files.freeze)
      formatter_set.close_output_files
    end

    def build_conductor(files)
      puts 'Running parallel inspection' if @options[:debug]
      klass = InspectConductor.conductor_class(@options[:parallel])
      klass.new(files, formatter_set, @options[:fail_fast])
    end

    def list_files(paths)
      paths.each do |path|
        puts PathUtil.relative_path(path)
      end
    end

    def process_file(file)
      puts "Scanning #{file}" if @options[:debug]
      file_started(file)

      result = file_offenses(file)
      if @options[:display_only_fail_level_offenses]
        result.offenses = result.offenses.select { |o| considered_failure?(o) }
      end

      passed = result.offenses.none?(&method(:considered_failure?))
      ProcessResult.build_succeed_result(file, result, passed)
    rescue InfiniteCorrectionLoop => e
      ProcessResult.build_error_result(file, e)
    end

    def file_offenses(file)
      file_offense_cache(file) do
        source = get_processed_source(file)
        source, result = do_inspection_loop(file, source)

        offenses = result.offenses.compact.sort
        result.offenses = add_unneeded_disables(file, offenses, source)

        result
      end
    end

    def file_offense_cache(file)
      cache = ResultCache.new(file, @options, @config_store) if cached_run?
      if cache&.valid?
        result = InspectResult.new
        result.offenses = cache.load

        # If we're running --auto-correct and the cache says there are
        # offenses, we need to actually inspect the file. If the cache shows no
        # offenses, we're good.
        real_run_needed = @options[:auto_correct] && result.offenses.any?
      else
        real_run_needed = true
      end

      if real_run_needed
        result = yield
        save_in_cache(cache, result)
      end

      result
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

    def save_in_cache(cache, inspect_result)
      return unless cache
      # Caching results when a cop has crashed would prevent the crash in the
      # next run, since the cop would not be called then. We want crashes to
      # show up the same in each run.
      return if inspect_result.errors.any? || inspect_result.warnings.any?

      cache.save(inspect_result.offenses)
    end

    def do_inspection_loop(file, processed_source)
      r = InspectResult.new

      offenses = []

      # When running with --auto-correct, we need to inspect the file (which
      # includes writing a corrected version of it) until no more corrections
      # are made. This is because automatic corrections can introduce new
      # offenses. In the normal case the loop is only executed once.
      iterate_until_no_changes(processed_source, offenses) do
        # The offenses that couldn't be corrected will be found again so we
        # only keep the corrected ones in order to avoid duplicate reporting.
        offenses.select!(&:corrected?)
        new_offenses, updated_source_file, e, w = inspect_file(processed_source)
        r.errors.concat(e)
        r.warnings.concat(w)
        offenses.concat(new_offenses).uniq!

        # We have to reprocess the source to pickup the changes. Since the
        # change could (theoretically) introduce parsing errors, we break the
        # loop if we find any.
        break unless updated_source_file

        processed_source = get_processed_source(file)
      end

      r.offenses = offenses
      [processed_source, r]
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
      team = Cop::Team.new(mobilized_cop_classes(config), config, @options)
      offenses = team.inspect_file(processed_source)
      [offenses, team.updated_source_file?, team.errors, team.warnings]
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
