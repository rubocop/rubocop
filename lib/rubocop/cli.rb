# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module RuboCop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    include Formatter::TextUtil

    SKIPPED_PHASE_1 = 'Phase 1 of 2: run Metrics/LineLength cop (skipped ' \
                      'because the default Metrics/LineLength:Max is ' \
                      'overridden)'.freeze
    STATUS_SUCCESS  = 0
    STATUS_OFFENSES = 1
    STATUS_ERROR    = 2

    class Finished < RuntimeError; end

    attr_reader :options, :config_store

    def initialize
      @options = {}
      @config_store = ConfigStore.new
    end

    # @api public
    #
    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files.
    #
    # @param args [Array<String>] command line arguments
    # @return [Integer] UNIX exit code
    #
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def run(args = ARGV)
      @options, paths = Options.new.parse(args)
      validate_options_vs_config
      act_on_options
      apply_default_formatter
      execute_runners(paths)
    rescue RuboCop::ConfigNotFoundError => e
      warn e.message
      STATUS_ERROR
    rescue RuboCop::Error => e
      warn Rainbow("Error: #{e.message}").red
      STATUS_ERROR
    rescue Finished
      STATUS_SUCCESS
    rescue IncorrectCopNameError => e
      warn e.message
      STATUS_ERROR
    rescue OptionParser::InvalidOption => e
      warn e.message
      warn 'For usage information, use --help'
      STATUS_ERROR
    rescue StandardError, SyntaxError, LoadError => e
      warn e.message
      warn e.backtrace
      STATUS_ERROR
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def trap_interrupt(runner)
      Signal.trap('INT') do
        exit!(1) if runner.aborting?
        runner.abort
        warn
        warn 'Exiting... Interrupt again to exit immediately.'
      end
    end

    private

    def execute_runners(paths)
      if @options[:auto_gen_config]
        reset_config_and_auto_gen_file
        line_length_contents =
          if max_line_length(@config_store.for(Dir.pwd)) ==
             max_line_length(ConfigLoader.default_configuration)
            run_line_length_cop_auto_gen_config(paths)
          else
            puts Rainbow(SKIPPED_PHASE_1).yellow
            ''
          end
        run_all_cops_auto_gen_config(line_length_contents, paths)
      else
        execute_runner(paths)
      end
    end

    def max_line_length(config)
      config.for_cop('Metrics/LineLength')['Max']
    end

    # Do an initial run with only Metrics/LineLength so that cops that depend
    # on Metrics/LineLength:Max get the correct value for that parameter.
    def run_line_length_cop_auto_gen_config(paths)
      puts Rainbow('Phase 1 of 2: run Metrics/LineLength cop').yellow
      @options[:only] = ['Metrics/LineLength']
      execute_runner(paths)
      @options.delete(:only)
      @config_store = ConfigStore.new
      # Save the todo configuration of the LineLength cop.
      IO.read(ConfigLoader::AUTO_GENERATED_FILE)
        .lines
        .drop_while { |line| line.start_with?('#') }
        .join
    end

    def run_all_cops_auto_gen_config(line_length_contents, paths)
      puts Rainbow('Phase 2 of 2: run all cops').yellow
      result = execute_runner(paths)
      # This run was made with the current maximum length allowed, so append
      # the saved setting for LineLength.
      File.open(ConfigLoader::AUTO_GENERATED_FILE, 'a') do |f|
        f.write(line_length_contents)
      end
      result
    end

    def reset_config_and_auto_gen_file
      @config_store = ConfigStore.new
      File.open(ConfigLoader::AUTO_GENERATED_FILE, 'w') {}
      ConfigLoader.add_inheritance_from_auto_generated_file
    end

    def validate_options_vs_config
      if @options[:parallel] &&
         !@config_store.for(Dir.pwd).for_all_cops['UseCache']
        raise ArgumentError, '-P/--parallel uses caching to speed up ' \
                             'execution, so combining with AllCops: ' \
                             'UseCache: false is not allowed.'
      end
    end

    def act_on_options
      ConfigLoader.debug = @options[:debug]
      ConfigLoader.auto_gen_config = @options[:auto_gen_config]
      ConfigLoader.ignore_parent_exclusion = @options[:ignore_parent_exclusion]

      @config_store.options_config = @options[:config] if @options[:config]
      @config_store.force_default_config! if @options[:force_default_config]

      handle_exiting_options

      if @options[:color]
        # color output explicitly forced on
        Rainbow.enabled = true
      elsif @options[:color] == false
        # color output explicitly forced off
        Rainbow.enabled = false
      end
    end

    def execute_runner(paths)
      runner = Runner.new(@options, @config_store)

      trap_interrupt(runner)
      all_passed = runner.run(paths)
      display_warning_summary(runner.warnings)
      display_error_summary(runner.errors)
      maybe_print_corrected_source

      if all_passed && !runner.aborting? && runner.errors.empty?
        STATUS_SUCCESS
      else
        STATUS_OFFENSES
      end
    end

    def handle_exiting_options
      return unless Options::EXITING_OPTIONS.any? { |o| @options.key? o }

      puts RuboCop::Version.version(false) if @options[:version]
      puts RuboCop::Version.version(true) if @options[:verbose_version]
      print_available_cops if @options[:show_cops]
      raise Finished
    end

    def apply_default_formatter
      # This must be done after the options have already been processed,
      # because they can affect how ConfigStore behaves
      @options[:formatters] ||= begin
        if @options[:auto_gen_config]
          formatter = 'autogenconf'
        else
          cfg = @config_store.for(Dir.pwd).for_all_cops
          formatter = cfg['DefaultFormatter'] || 'progress'
        end
        [[formatter, @options[:output_path]]]
      end

      return unless @options[:auto_gen_config]

      @options[:formatters] << [Formatter::DisabledConfigFormatter,
                                ConfigLoader::AUTO_GENERATED_FILE]
    end

    def print_available_cops
      # Load the configs so the require()s are done for custom cops
      @config_store.for(Dir.pwd)
      registry = Cop::Cop.registry
      show_all = @options[:show_cops].empty?

      if show_all
        puts "# Available cops (#{registry.length}) + config for #{Dir.pwd}: "
      end

      registry.departments.sort!.each do |department|
        print_cops_of_department(registry, department, show_all)
      end
    end

    def print_cops_of_department(registry, department, show_all)
      selected_cops = if show_all
                        cops_of_department(registry, department)
                      else
                        selected_cops_of_department(registry, department)
                      end

      puts "# Department '#{department}' (#{selected_cops.length}):" if show_all

      print_cop_details(selected_cops)
    end

    def print_cop_details(cops)
      cops.each do |cop|
        puts '# Supports --auto-correct' if cop.new.support_autocorrect?
        puts "#{cop.cop_name}:"
        puts config_lines(cop)
        puts
      end
    end

    def selected_cops_of_department(cops, department)
      cops_of_department(cops, department).select do |cop|
        @options[:show_cops].include?(cop.cop_name)
      end
    end

    def cops_of_department(cops, department)
      cops.with_department(department).sort!
    end

    def config_lines(cop)
      cnf = @config_store.for(Dir.pwd).for_cop(cop)
      cnf.to_yaml.lines.to_a.butfirst.map { |line| '  ' + line }
    end

    def display_warning_summary(warnings)
      return if warnings.empty?

      warn Rainbow("\n#{pluralize(warnings.size, 'warning')}:").yellow

      warnings.each { |warning| warn warning }
    end

    def display_error_summary(errors)
      return if errors.empty?

      warn Rainbow("\n#{pluralize(errors.size, 'error')} occurred:").red

      errors.each { |error| warn error }

      warn <<-WARNING.strip_indent
        Errors are usually caused by RuboCop bugs.
        Please, report your problems to RuboCop's issue tracker.
        #{Gem.loaded_specs['rubocop'].metadata['bug_tracker_uri']}

        Mention the following information in the issue report:
        #{RuboCop::Version.version(true)}
      WARNING
    end

    def maybe_print_corrected_source
      # If we are asked to autocorrect source code read from stdin, the only
      # reasonable place to write it is to stdout
      # Unfortunately, we also write other information to stdout
      # So a delimiter is needed for tools to easily identify where the
      # autocorrected source begins
      return unless @options[:stdin] && @options[:auto_correct]
      puts '=' * 20
      print @options[:stdin]
    end
  end
end
# rubocop:enable Metrics/ClassLength
