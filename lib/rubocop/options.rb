# frozen_string_literal: true

require 'optparse'
require 'shellwords'

module RuboCop
  class IncorrectCopNameError < StandardError; end
  class OptionArgumentError < StandardError; end

  # This class handles command line options.
  class Options
    E_STDIN_NO_PATH = '-s/--stdin requires exactly one path, relative to the ' \
      'root of the project. RuboCop will use this path to determine which ' \
      'cops are enabled (via eg. Include/Exclude), and so that certain cops ' \
      'like Naming/FileName can be checked.'
    EXITING_OPTIONS = %i[version verbose_version show_cops].freeze
    DEFAULT_MAXIMUM_EXCLUSION_ITEMS = 15

    def initialize
      @options = {}
      @validator = OptionsValidator.new(@options)
    end

    def parse(command_line_args)
      args = args_from_file.concat(args_from_env).concat(command_line_args)
      define_options.parse!(args)

      @validator.validate_compatibility

      if @options[:stdin]
        # The parser will put the file name given after --stdin into
        # @options[:stdin]. If it did, then the args array should be empty.
        raise OptionArgumentError, E_STDIN_NO_PATH if args.any?

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
        File.read('.rubocop').shellsplit
      else
        []
      end
    end

    def args_from_env
      Shellwords.split(ENV.fetch('RUBOCOP_OPTS', ''))
    end

    def define_options
      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        add_list_options(opts)
        add_only_options(opts)
        add_configuration_options(opts)
        add_formatting_options(opts)

        option(opts, '-r', '--require FILE') { |f| require f }

        add_severity_option(opts)
        add_flags_with_optional_args(opts)
        add_boolean_flags(opts)
        add_aliases(opts)

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
        unless list
          message = "--#{option} argument should be [COP1,COP2,...]."

          raise OptionArgumentError, message
        end

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

    def add_configuration_options(opts)
      option(opts, '-c', '--config FILE')
      option(opts, '--force-exclusion')
      option(opts, '--only-recognized-file-types')
      option(opts, '--ignore-parent-exclusion')
      option(opts, '--force-default-config')
      add_auto_gen_options(opts)
    end

    def add_auto_gen_options(opts)
      option(opts, '--auto-gen-config')

      option(opts, '--exclude-limit COUNT') do
        @validator.validate_exclude_limit_option
      end

      option(opts, '--disable-uncorrectable')

      option(opts, '--no-offense-counts') do
        @options[:no_offense_counts] = true
      end

      option(opts, '--auto-gen-only-exclude')
      option(opts, '--no-auto-gen-timestamp') do
        @options[:no_auto_gen_timestamp] = true
      end

      option(opts, '--init')
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

      option(opts, '--display-only-failed')
    end

    def add_severity_option(opts)
      table = RuboCop::Cop::Severity::CODE_TABLE.merge(A: :autocorrect)
      option(opts, '--fail-level SEVERITY',
             RuboCop::Cop::Severity::NAMES + [:autocorrect],
             table) do |severity|
        @options[:fail_level] = severity
      end
      option(opts, '--display-only-fail-level-offenses')
    end

    def add_flags_with_optional_args(opts)
      option(opts, '--show-cops [COP1,COP2,...]') do |list|
        @options[:show_cops] = list.nil? ? [] : list.split(',')
      end
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def add_boolean_flags(opts)
      option(opts, '-F', '--fail-fast')
      option(opts, '-C', '--cache FLAG')
      option(opts, '-d', '--debug')
      option(opts, '-D', '--[no-]display-cop-names')
      option(opts, '-E', '--extra-details')
      option(opts, '-S', '--display-style-guide')
      option(opts, '-a', '--auto-correct') do
        @options[:safe_auto_correct] = true
      end
      option(opts, '--safe-autocorrect') do
        warn '--safe-autocorrect is deprecated; use --autocorrect'
        @options[:safe_auto_correct] = @options[:auto_correct] = true
      end
      option(opts, '-A', '--auto-correct-all') do
        @options[:auto_correct] = true
      end
      option(opts, '--disable-pending-cops')
      option(opts, '--enable-pending-cops')
      option(opts, '--ignore-disable-comments')

      option(opts, '--safe')

      option(opts, '--[no-]color')

      option(opts, '-v', '--version')
      option(opts, '-V', '--verbose-version')
      option(opts, '-P', '--parallel')
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def add_aliases(opts)
      option(opts, '-l', '--lint') do
        @options[:only] ||= []
        @options[:only] << 'Lint'
      end
      option(opts, '-x', '--fix-layout') do
        @options[:only] ||= []
        @options[:only] << 'Layout'
        @options[:auto_correct] = true
      end
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

          raise IncorrectCopNameError, format_message_from(name, cop_names)
        end
      end

      private

      def format_message_from(name, cop_names)
        message = 'Unrecognized cop or department: %<name>s.'
        message_with_candidate = "%<message>s\nDid you mean? %<candidate>s"
        corrections = NameSimilarity.find_similar_names(name, cop_names)

        if corrections.empty?
          format(message, name: name)
        else
          format(message_with_candidate, message: format(message, name: name),
                                         candidate: corrections.join(', '))
        end
      end
    end

    def initialize(options)
      @options = options
    end

    def validate_cop_options
      %i[only except].each do |opt|
        OptionsValidator.validate_cop_list(@options[opt])
      end
    end

    # rubocop:disable Metrics/AbcSize
    def validate_compatibility # rubocop:disable Metrics/MethodLength
      if only_includes_redundant_disable?
        raise OptionArgumentError, 'Lint/RedundantCopDisableDirective cannot ' \
                                   'be used with --only.'
      end
      raise OptionArgumentError, 'Syntax checking cannot be turned off.' if except_syntax?
      unless boolean_or_empty_cache?
        raise OptionArgumentError, '-C/--cache argument must be true or false'
      end

      if display_only_fail_level_offenses_with_autocorrect?
        raise OptionArgumentError, '--autocorrect cannot be used with ' \
          '--display-only-fail-level-offenses'
      end
      validate_auto_gen_config
      validate_auto_correct
      validate_display_only_failed
      validate_parallel

      return if incompatible_options.size <= 1

      raise OptionArgumentError, 'Incompatible cli options: ' \
                                 "#{incompatible_options.inspect}"
    end
    # rubocop:enable Metrics/AbcSize

    def validate_auto_gen_config
      return if @options.key?(:auto_gen_config)

      message = '--%<flag>s can only be used together with --auto-gen-config.'

      %i[exclude_limit no_offense_counts no_auto_gen_timestamp
         auto_gen_only_exclude].each do |option|
        if @options.key?(option)
          raise OptionArgumentError,
                format(message, flag: option.to_s.tr('_', '-'))
        end
      end
    end

    def validate_display_only_failed
      return unless @options.key?(:display_only_failed)
      return if @options[:format] == 'junit'

      raise OptionArgumentError,
            format('--display-only-failed can only be used together with --format junit.')
    end

    def validate_auto_correct
      return if @options.key?(:auto_correct)
      return unless @options.key?(:disable_uncorrectable)

      raise OptionArgumentError,
            format('--disable-uncorrectable can only be used together with --auto-correct.')
    end

    def validate_parallel
      return unless @options.key?(:parallel)

      if @options[:cache] == 'false'
        raise OptionArgumentError, '-P/--parallel uses caching to speed up ' \
                                   'execution, so combining with --cache ' \
                                   'false is not allowed.'
      end

      validate_parallel_with_combo_option
    end

    def validate_parallel_with_combo_option
      combos = {
        auto_gen_config: '-P/--parallel uses caching to speed up execution, ' \
                         'while --auto-gen-config needs a non-cached run, ' \
                         'so they cannot be combined.',
        fail_fast: '-P/--parallel cannot be combined with -F/--fail-fast.',
        auto_correct: '-P/--parallel cannot be combined with --auto-correct.'
      }

      combos.each do |key, msg|
        raise OptionArgumentError, msg if @options.key?(key)
      end
    end

    def only_includes_redundant_disable?
      @options.key?(:only) &&
        (@options[:only] & %w[Lint/RedundantCopDisableDirective
                              RedundantCopDisableDirective]).any?
    end

    def display_only_fail_level_offenses_with_autocorrect?
      @options[:display_only_fail_level_offenses] && @options[:autocorrect]
    end

    def except_syntax?
      @options.key?(:except) &&
        (@options[:except] & %w[Lint/Syntax Syntax]).any?
    end

    def boolean_or_empty_cache?
      !@options.key?(:cache) || %w[true false].include?(@options[:cache])
    end

    def incompatible_options
      @incompatible_options ||= @options.keys & Options::EXITING_OPTIONS
    end

    def validate_exclude_limit_option
      return if /^\d+$/.match?(@options[:exclude_limit])

      # Emulate OptionParser's behavior to make failures consistent regardless
      # of option order.
      raise OptionParser::MissingArgument
    end
  end

  # This module contains help texts for command line options.
  module OptionsHelp
    MAX_EXCL = RuboCop::Options::DEFAULT_MAXIMUM_EXCLUSION_ITEMS.to_s
    FORMATTER_OPTION_LIST = RuboCop::Formatter::FormatterSet::BUILTIN_FORMATTERS_FOR_KEYS.keys

    TEXT = {
      only:                             'Run only the given cop(s).',
      only_guide_cops:                  ['Run only cops for rules that link to a',
                                         'style guide.'],
      except:                           'Disable the given cop(s).',
      require:                          'Require Ruby file.',
      config:                           'Specify configuration file.',
      auto_gen_config:                  ['Generate a configuration file acting as a',
                                         'TODO list.'],
      no_offense_counts:                ['Do not include offense counts in configuration',
                                         'file generated by --auto-gen-config.'],
      no_auto_gen_timestamp:
                                        ['Do not include the date and time when',
                                         'the --auto-gen-config was run in the file it',
                                         'generates.'],
      auto_gen_only_exclude:
                                        ['Generate only Exclude parameters and not Max',
                                         'when running --auto-gen-config, except if the',
                                         'number of files with offenses is bigger than',
                                         'exclude-limit.'],
      exclude_limit:                    ['Used together with --auto-gen-config to',
                                         'set the limit for how many Exclude',
                                         "properties to generate. Default is #{MAX_EXCL}."],
      disable_uncorrectable:            ['Used with --auto-correct to annotate any',
                                         'offenses that do not support autocorrect',
                                         'with `rubocop:todo` comments.'],
      force_exclusion:                  ['Force excluding files specified in the',
                                         'configuration `Exclude` even if they are',
                                         'explicitly passed as arguments.'],
      only_recognized_file_types:       ['Inspect files given on the command line only if',
                                         'they are listed in AllCops/Include parameters',
                                         'of user configuration or default configuration.'],
      ignore_disable_comments:          ['Run cops even when they are disabled locally',
                                         'with a comment.'],
      ignore_parent_exclusion:          ['Prevent from inheriting AllCops/Exclude from',
                                         'parent folders.'],
      force_default_config:             ['Use default configuration even if configuration',
                                         'files are present in the directory tree.'],
      format:                           ['Choose an output formatter. This option',
                                         'can be specified multiple times to enable',
                                         'multiple formatters at the same time.',
                                         '[p]rogress is used by default',
                                         *FORMATTER_OPTION_LIST.map { |item| "  #{item}" },
                                         '  custom formatter class name'],
      out:                              ['Write output to a file instead of STDOUT.',
                                         'This option applies to the previously',
                                         'specified --format, or the default format',
                                         'if no format is specified.'],
      fail_level:                       ['Minimum severity (A/R/C/W/E/F) for exit',
                                         'with error code.'],
      display_only_failed:              ['Only output offense messages. Omit passing',
                                         'cops. Only valid for --format junit.'],
      display_only_fail_level_offenses:
                                        ['Only output offense messages at',
                                         'the specified --fail-level or above'],
      show_cops:                        ['Shows the given cops, or all cops by',
                                         'default, and their configurations for the',
                                         'current directory.'],
      fail_fast:                        ['Inspect files in order of modification',
                                         'time and stop after the first file',
                                         'containing offenses.'],
      cache:                            ["Use result caching (FLAG=true) or don't",
                                         '(FLAG=false), default determined by',
                                         'configuration parameter AllCops: UseCache.'],
      debug:                            'Display debug info.',
      display_cop_names:                ['Display cop names in offense messages.',
                                         'Default is true.'],
      disable_pending_cops:             'Run without pending cops.',
      display_style_guide:              'Display style guide URLs in offense messages.',
      enable_pending_cops:              'Run with pending cops.',
      extra_details:                    'Display extra details in offense messages.',
      lint:                             'Run only lint cops.',
      safe:                             'Run only safe cops.',
      list_target_files:                'List all files RuboCop will inspect.',
      auto_correct:                     'Auto-correct offenses (only when it\'s safe).',
      safe_autocorrect:                 '(same, deprecated)',
      auto_correct_all:                 'Auto-correct offenses (safe and unsafe)',
      fix_layout:                       'Run only layout cops, with auto-correct on.',
      color:                            'Force color output on or off.',
      version:                          'Display version.',
      verbose_version:                  'Display verbose version.',
      parallel:                         ['Use available CPUs to execute inspection in',
                                         'parallel.'],
      stdin:                            ['Pipe source from STDIN, using FILE in offense',
                                         'reports. This is useful for editor integration.'],
      init:                             'Generate a .rubocop.yml file in the current directory.'
    }.freeze
  end
end
