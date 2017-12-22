# frozen_string_literal: true

require 'optparse'
require 'shellwords'

module RuboCop
  # This class handles command line options.
  class Options
    EXITING_OPTIONS = %i[version verbose_version show_cops].freeze
    DEFAULT_MAXIMUM_EXCLUSION_ITEMS = 15

    def initialize
      @options = {}
      @validator = OptionsValidator.new(@options)
    end

    def parse(command_line_args)
      args = args_from_file.concat(args_from_env).concat(command_line_args)
      define_options(args).parse!(args)

      @validator.validate_compatibility

      if @options[:stdin]
        # The parser has put the file name given after --stdin into
        # @options[:stdin]. The args array should be empty.
        if args.any?
          raise ArgumentError, '-s/--stdin requires exactly one path.'
        end
        # We want the STDIN contents in @options[:stdin] and the file name in
        # args to simplify the rest of the processing.
        args = [@options[:stdin]]
        @options[:stdin] = $stdin.binmode.read
      end

      [@options, args]
    end

    private

    def args_from_file
      if File.exist?('.rubocop') && !File.directory?('.rubocop')
        IO.readlines('.rubocop').map(&:strip)
      else
        []
      end
    end

    def args_from_env
      Shellwords.split(ENV.fetch('RUBOCOP_OPTS', ''))
    end

    def define_options(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        add_list_options(opts)
        add_only_options(opts)
        add_configuration_options(opts, args)
        add_formatting_options(opts)

        option(opts, '-r', '--require FILE') { |f| require f }

        add_severity_option(opts)
        add_flags_with_optional_args(opts)
        add_boolean_flags(opts)

        option(opts, '-s', '--stdin FILE')
      end
    end

    def add_only_options(opts)
      add_cop_selection_csv_option('except', opts)
      add_cop_selection_csv_option('only', opts)
      option(opts, '--only-guide-cops')
    end

    def add_cop_selection_csv_option(option, opts)
      option(opts, "--#{option} [COP1,COP2,...]") do |list|
        @options[:"#{option}"] =
          if list.empty?
            ['']
          else
            list.split(',').map do |c|
              Cop::Cop.qualified_cop_name(c, "--#{option} option")
            end
          end
      end
    end

    def add_configuration_options(opts, args)
      option(opts, '-c', '--config FILE')

      option(opts, '--auto-gen-config')

      option(opts, '--exclude-limit COUNT') do
        @validator.validate_exclude_limit_option(args)
      end

      option(opts, '--force-exclusion')
      option(opts, '--ignore-parent-exclusion')

      option(opts, '--force-default-config')

      option(opts, '--no-offense-counts') do
        @options[:no_offense_counts] = true
      end
    end

    def add_formatting_options(opts)
      option(opts, '-f', '--format FORMATTER') do |key|
        @options[:formatters] ||= []
        @options[:formatters] << [key]
      end

      option(opts, '-o', '--out FILE') do |path|
        if @options[:formatters]
          @options[:formatters].last << path
        else
          @options[:output_path] = path
        end
      end
    end

    def add_severity_option(opts)
      table = RuboCop::Cop::Severity::CODE_TABLE.merge(A: :autocorrect)
      option(opts, '--fail-level SEVERITY',
             RuboCop::Cop::Severity::NAMES + [:autocorrect],
             table) do |severity|
        @options[:fail_level] = severity
      end
    end

    def add_flags_with_optional_args(opts)
      option(opts, '--show-cops [COP1,COP2,...]') do |list|
        @options[:show_cops] = list.nil? ? [] : list.split(',')
      end
    end

    def add_boolean_flags(opts) # rubocop:disable Metrics/MethodLength
      option(opts, '-F', '--fail-fast')
      option(opts, '-C', '--cache FLAG')
      option(opts, '-d', '--debug')
      option(opts, '-D', '--[no-]display-cop-names')
      option(opts, '-E', '--extra-details')
      option(opts, '-S', '--display-style-guide')
      option(opts, '-R', '--rails')
      option(opts, '-l', '--lint') do
        @options[:only] ||= []
        @options[:only] << 'Lint'
      end
      option(opts, '-a', '--auto-correct')

      option(opts, '--[no-]color')

      option(opts, '-v', '--version')
      option(opts, '-V', '--verbose-version')
      option(opts, '-P', '--parallel')
    end

    def add_list_options(opts)
      option(opts, '-L', '--list-target-files')
    end

    # Sets a value in the @options hash, based on the given long option and its
    # value, in addition to calling the block if a block is given.
    def option(opts, *args)
      long_opt_symbol = long_opt_symbol(args)
      args += Array(OptionsHelp::TEXT[long_opt_symbol])
      opts.on(*args) do |arg|
        @options[long_opt_symbol] = arg
        yield arg if block_given?
      end
    end

    # Finds the option in `args` starting with -- and converts it to a symbol,
    # e.g. [..., '--auto-correct', ...] to :auto_correct.
    def long_opt_symbol(args)
      long_opt = args.find { |arg| arg.start_with?('--') }
      long_opt[2..-1].sub('[no-]', '').sub(/ .*/, '')
                     .tr('-', '_').gsub(/[\[\]]/, '').to_sym
    end
  end

  # Validates option arguments and the options' compatibility with each other.
  class OptionsValidator
    class << self
      # Cop name validation must be done later than option parsing, so it's not
      # called from within Options.
      def validate_cop_list(names)
        return unless names

        cop_names = Cop::Cop.registry.names
        departments = Cop::Cop.registry.departments.map(&:to_s)

        names.each do |name|
          next if cop_names.include?(name)
          next if departments.include?(name)
          next if %w[Syntax Lint/Syntax].include?(name)

          raise ArgumentError, format_message_from(name, cop_names)
        end
      end

      private

      def format_message_from(name, cop_names)
        message = 'Unrecognized cop or department: %{name}.'
        message_with_candidate = "#{message}\nDid you mean? %{candidate}"
        corrections = cop_names.select { |cn| cn =~ /\A#{name}/ }.sort

        if corrections.empty?
          format message, name: name
        else
          format message_with_candidate, name: name,
                                         candidate: corrections.join(', ')
        end
      end
    end

    def initialize(options)
      @options = options
    end

    def validate_compatibility # rubocop:disable Metrics/MethodLength
      if only_includes_unneeded_disable?
        raise ArgumentError, 'Lint/UnneededDisable can not be used with --only.'
      end
      if except_syntax?
        raise ArgumentError, 'Syntax checking can not be turned off.'
      end
      unless boolean_or_empty_cache?
        raise ArgumentError, '-C/--cache argument must be true or false'
      end
      if no_offense_counts_without_auto_gen_config?
        raise ArgumentError, '--no-offense-counts can only be used together ' \
                             'with --auto-gen-config.'
      end
      validate_parallel

      return if incompatible_options.size <= 1
      raise ArgumentError, 'Incompatible cli options: ' \
                           "#{incompatible_options.inspect}"
    end

    def validate_parallel
      return unless @options.key?(:parallel)

      if @options[:cache] == 'false'
        raise ArgumentError, '-P/--parallel uses caching to speed up ' \
                             'execution, so combining with --cache false is ' \
                             'not allowed.'
      end

      combos = {
        auto_gen_config: '-P/--parallel uses caching to speed up execution, ' \
                         'while --auto-gen-config needs a non-cached run, ' \
                         'so they cannot be combined.',
        fail_fast: '-P/--parallel can not be combined with -F/--fail-fast.',
        auto_correct: '-P/--parallel can not be combined with --auto-correct.'
      }

      combos.each { |key, msg| raise ArgumentError, msg if @options.key?(key) }
    end

    def only_includes_unneeded_disable?
      @options.key?(:only) &&
        (@options[:only] & %w[Lint/UnneededDisable UnneededDisable]).any?
    end

    def except_syntax?
      @options.key?(:except) &&
        (@options[:except] & %w[Lint/Syntax Syntax]).any?
    end

    def boolean_or_empty_cache?
      !@options.key?(:cache) || %w[true false].include?(@options[:cache])
    end

    def no_offense_counts_without_auto_gen_config?
      @options.key?(:no_offense_counts) && !@options.key?(:auto_gen_config)
    end

    def incompatible_options
      @incompatible_options ||= @options.keys & Options::EXITING_OPTIONS
    end

    def validate_exclude_limit_option(args)
      if @options[:exclude_limit] !~ /^\d+$/
        # Emulate OptionParser's behavior to make failures consistent regardless
        # of option order.
        raise OptionParser::MissingArgument
      end

      # --exclude-limit is valid if there's a parsed or yet unparsed
      # --auto-gen-config.
      return if @options[:auto_gen_config] || args.include?('--auto-gen-config')

      raise ArgumentError,
            '--exclude-limit can only be used with --auto-gen-config.'
    end
  end

  # This module contains help texts for command line options.
  module OptionsHelp
    MAX_EXCL = RuboCop::Options::DEFAULT_MAXIMUM_EXCLUSION_ITEMS.to_s
    TEXT = {
      only:                  'Run only the given cop(s).',
      only_guide_cops:      ['Run only cops for rules that link to a',
                             'style guide.'],
      except:                'Disable the given cop(s).',
      require:               'Require Ruby file.',
      config:                'Specify configuration file.',
      auto_gen_config:      ['Generate a configuration file acting as a',
                             'TODO list.'],
      no_offense_counts:    ['Do not include offense counts in configuration',
                             'file generated by --auto-gen-config.'],
      exclude_limit:        ['Used together with --auto-gen-config to',
                             'set the limit for how many Exclude',
                             "properties to generate. Default is #{MAX_EXCL}."],
      force_exclusion:      ['Force excluding files specified in the',
                             'configuration `Exclude` even if they are',
                             'explicitly passed as arguments.'],
      ignore_parent_exclusion:
                            ['Prevent from inheriting AllCops/Exclude from',
                             'parent folders.'],
      force_default_config: ['Use default configuration even if configuration',
                             'files are present in the directory tree.'],
      format:               ['Choose an output formatter. This option',
                             'can be specified multiple times to enable',
                             'multiple formatters at the same time.',
                             '  [p]rogress (default)',
                             '  [s]imple',
                             '  [c]lang',
                             '  [d]isabled cops via inline comments',
                             '  [fu]ubar',
                             '  [e]macs',
                             '  [j]son',
                             '  [h]tml',
                             '  [fi]les',
                             '  [o]ffenses',
                             '  [w]orst',
                             '  [t]ap',
                             '  [q]uiet',
                             '  custom formatter class name'],
      out:                  ['Write output to a file instead of STDOUT.',
                             'This option applies to the previously',
                             'specified --format, or the default format',
                             'if no format is specified.'],
      fail_level:           ['Minimum severity (A/R/C/W/E/F) for exit',
                             'with error code.'],
      show_cops:            ['Shows the given cops, or all cops by',
                             'default, and their configurations for the',
                             'current directory.'],
      fail_fast:            ['Inspect files in order of modification',
                             'time and stop after the first file',
                             'containing offenses.'],
      cache:                ["Use result caching (FLAG=true) or don't",
                             '(FLAG=false), default determined by',
                             'configuration parameter AllCops: UseCache.'],
      debug:                 'Display debug info.',
      display_cop_names:     ['Display cop names in offense messages.',
                              'Default is true.'],
      display_style_guide:   'Display style guide URLs in offense messages.',
      extra_details:         'Display extra details in offense messages.',
      rails:                 'Run extra Rails cops.',
      lint:                  'Run only lint cops.',
      list_target_files:     'List all files RuboCop will inspect.',
      auto_correct:          'Auto-correct offenses.',
      color:                 'Force color output on or off.',
      version:               'Display version.',
      verbose_version:       'Display verbose version.',
      parallel:             ['Use available CPUs to execute inspection in',
                             'parallel.'],
      stdin:                ['Pipe source from STDIN, using FILE in offense',
                             'reports. This is useful for editor integration.']
    }.freeze
  end
end
