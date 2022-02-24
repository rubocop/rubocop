# frozen_string_literal: true

require 'optparse'
require 'shellwords'

module RuboCop
  class IncorrectCopNameError < StandardError; end

  class OptionArgumentError < StandardError; end

  # This class handles command line options.
  # @api private
  class Options
    E_STDIN_NO_PATH = '-s/--stdin requires exactly one path, relative to the ' \
                      'root of the project. RuboCop will use this path to determine which ' \
                      'cops are enabled (via eg. Include/Exclude), and so that certain cops ' \
                      'like Naming/FileName can be checked.'
    EXITING_OPTIONS = %i[version verbose_version show_cops show_docs_url].freeze
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
        opts.banner = rainbow.wrap('Usage: rubocop [options] [file1, file2, ...]').bright

        add_check_options(opts)
        add_cache_options(opts)
        add_output_options(opts)
        add_autocorrection_options(opts)
        add_config_generation_options(opts)
        add_additional_modes(opts)
        add_general_options(opts)
      end
    end

    def add_check_options(opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      section(opts, 'Basic Options') do
        option(opts, '-l', '--lint') do
          @options[:only] ||= []
          @options[:only] << 'Lint'
        end
        option(opts, '-x', '--fix-layout') do
          @options[:only] ||= []
          @options[:only] << 'Layout'
          @options[:auto_correct] = true
        end
        option(opts, '--safe')
        add_cop_selection_csv_option('except', opts)
        add_cop_selection_csv_option('only', opts)
        option(opts, '--only-guide-cops')
        option(opts, '-F', '--fail-fast')
        option(opts, '--disable-pending-cops')
        option(opts, '--enable-pending-cops')
        option(opts, '--ignore-disable-comments')
        option(opts, '--force-exclusion')
        option(opts, '--only-recognized-file-types')
        option(opts, '--ignore-parent-exclusion')
        option(opts, '--force-default-config')
        option(opts, '-s', '--stdin FILE')
        option(opts, '-P', '--[no-]parallel')
        add_severity_option(opts)
      end
    end

    def add_output_options(opts) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      section(opts, 'Output Options') do
        option(opts, '-f', '--format FORMATTER') do |key|
          @options[:formatters] ||= []
          @options[:formatters] << [key]
        end

        option(opts, '-D', '--[no-]display-cop-names')
        option(opts, '-E', '--extra-details')
        option(opts, '-S', '--display-style-guide')

        option(opts, '-o', '--out FILE') do |path|
          if @options[:formatters]
            @options[:formatters].last << path
          else
            @options[:output_path] = path
          end
        end

        option(opts, '--stderr')
        option(opts, '--display-time')
        option(opts, '--display-only-failed')
        option(opts, '--display-only-fail-level-offenses')
      end
    end

    def add_autocorrection_options(opts)
      section(opts, 'Auto-correction') do
        option(opts, '-a', '--auto-correct') { @options[:safe_auto_correct] = true }
        option(opts, '--safe-auto-correct') do
          warn '--safe-auto-correct is deprecated; use --auto-correct'
          @options[:safe_auto_correct] = @options[:auto_correct] = true
        end
        option(opts, '-A', '--auto-correct-all') { @options[:auto_correct] = true }
        option(opts, '--disable-uncorrectable')
      end
    end

    def add_config_generation_options(opts)
      section(opts, 'Config Generation') do
        option(opts, '--auto-gen-config')

        option(opts, '--regenerate-todo') do
          @options.replace(ConfigRegeneration.new.options.merge(@options))
        end

        option(opts, '--exclude-limit COUNT') { @validator.validate_exclude_limit_option }

        option(opts, '--[no-]offense-counts')
        option(opts, '--[no-]auto-gen-only-exclude')
        option(opts, '--[no-]auto-gen-timestamp')
      end
    end

    def add_cop_selection_csv_option(option, opts)
      option(opts, "--#{option} [COP1,COP2,...]") do |list|
        unless list
          message = "--#{option} argument should be [COP1,COP2,...]."

          raise OptionArgumentError, message
        end

        @options[:"#{option}"] = list.empty? ? [''] : list.split(',')
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

    def add_cache_options(opts)
      section(opts, 'Caching') do
        option(opts, '-C', '--cache FLAG')
        option(opts, '--cache-root DIR') { @validator.validate_cache_enabled_for_cache_root }
      end
    end

    def add_additional_modes(opts)
      section(opts, 'Additional Modes') do
        option(opts, '-L', '--list-target-files')
        option(opts, '--show-cops [COP1,COP2,...]') do |list|
          @options[:show_cops] = list.nil? ? [] : list.split(',')
        end
        option(opts, '--show-docs-url [COP1,COP2,...]') do |list|
          @options[:show_docs_url] = list.nil? ? [] : list.split(',')
        end
      end
    end

    def add_general_options(opts)
      section(opts, 'General Options') do
        option(opts, '--init')
        option(opts, '-c', '--config FILE')
        option(opts, '-d', '--debug')
        option(opts, '-r', '--require FILE') { |f| require_feature(f) }
        option(opts, '--[no-]color')
        option(opts, '-v', '--version')
        option(opts, '-V', '--verbose-version')
      end
    end

    def rainbow
      @rainbow ||= begin
        rainbow = Rainbow.new
        rainbow.enabled = false if ARGV.include?('--no-color')
        rainbow
      end
    end

    # Creates a section of options in order to separate them visually when
    # using `--help`.
    def section(opts, heading, &_block)
      heading = rainbow.wrap(heading).bright
      opts.separator("\n#{heading}:\n")
      yield
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
      long_opt[2..-1].sub('[no-]', '').sub(/ .*/, '').tr('-', '_').gsub(/[\[\]]/, '').to_sym
    end

    def require_feature(file)
      # If any features were added on the CLI from `--require`,
      # add them to the config.
      ConfigLoader.add_loaded_features(file)
      require file
    end
  end

  # Validates option arguments and the options' compatibility with each other.
  # @api private
  class OptionsValidator
    class << self
      SYNTAX_DEPARTMENTS = %w[Syntax Lint/Syntax].freeze
      private_constant :SYNTAX_DEPARTMENTS

      # Cop name validation must be done later than option parsing, so it's not
      # called from within Options.
      def validate_cop_list(names)
        return unless names

        cop_names = Cop::Registry.global.names
        departments = Cop::Registry.global.departments.map(&:to_s)

        names.each do |name|
          next if cop_names.include?(name)
          next if departments.include?(name)
          next if SYNTAX_DEPARTMENTS.include?(name)

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
      %i[only except].each { |opt| OptionsValidator.validate_cop_list(@options[opt]) }
    end

    # rubocop:disable Metrics/AbcSize
    def validate_compatibility # rubocop:disable Metrics/MethodLength
      if only_includes_redundant_disable?
        raise OptionArgumentError, 'Lint/RedundantCopDisableDirective cannot be used with --only.'
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
      disable_parallel_when_invalid_option_combo

      return if incompatible_options.size <= 1

      raise OptionArgumentError, "Incompatible cli options: #{incompatible_options.inspect}"
    end
    # rubocop:enable Metrics/AbcSize

    def validate_auto_gen_config
      return if @options.key?(:auto_gen_config)

      message = '--%<flag>s can only be used together with --auto-gen-config.'

      %i[exclude_limit offense_counts auto_gen_timestamp
         auto_gen_only_exclude].each do |option|
        if @options.key?(option)
          raise OptionArgumentError, format(message, flag: option.to_s.tr('_', '-'))
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

    def disable_parallel_when_invalid_option_combo
      return unless @options.key?(:parallel)

      invalid_options = [
        { name: :auto_gen_config, value: true, flag: '--auto-gen-config' },
        { name: :fail_fast, value: true, flag: '-F/--fail-fast.' },
        { name: :auto_correct, value: true, flag: '--auto-correct.' },
        { name: :cache, value: 'false', flag: '--cache false' }
      ]

      invalid_flags = invalid_options.each_with_object([]) do |option, flags|
        # `>` rather than `>=` because `@options` will also contain `parallel: true`
        flags << option[:flag] if @options > { option[:name] => option[:value] }
      end

      return if invalid_flags.empty?

      @options.delete(:parallel)

      puts '-P/--parallel is being ignored because ' \
           "it is not compatible with #{invalid_flags.join(', ')}"
    end

    def only_includes_redundant_disable?
      @options.key?(:only) &&
        (@options[:only] & %w[Lint/RedundantCopDisableDirective RedundantCopDisableDirective]).any?
    end

    def display_only_fail_level_offenses_with_autocorrect?
      @options[:display_only_fail_level_offenses] && @options[:autocorrect]
    end

    def except_syntax?
      @options.key?(:except) && (@options[:except] & %w[Lint/Syntax Syntax]).any?
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

    def validate_cache_enabled_for_cache_root
      return unless @options[:cache] == 'false'

      raise OptionArgumentError, '--cache-root can not be used with --cache false'
    end
  end

  # This module contains help texts for command line options.
  # @api private
  module OptionsHelp
    MAX_EXCL = RuboCop::Options::DEFAULT_MAXIMUM_EXCLUSION_ITEMS.to_s
    FORMATTER_OPTION_LIST = RuboCop::Formatter::FormatterSet::BUILTIN_FORMATTERS_FOR_KEYS.keys

    TEXT = {
      only:                             'Run only the given cop(s).',
      only_guide_cops:                  ['Run only cops for rules that link to a',
                                         'style guide.'],
      except:                           'Exclude the given cop(s).',
      require:                          'Require Ruby file.',
      config:                           'Specify configuration file.',
      auto_gen_config:                  ['Generate a configuration file acting as a',
                                         'TODO list.'],
      regenerate_todo:                  ['Regenerate the TODO configuration file using',
                                         'the last configuration. If there is no existing',
                                         'TODO file, acts like --auto-gen-config.'],
      offense_counts:                   ['Include offense counts in configuration',
                                         'file generated by --auto-gen-config.',
                                         'Default is true.'],
      auto_gen_timestamp:
                                        ['Include the date and time when the --auto-gen-config',
                                         'was run in the file it generates. Default is true.'],
      auto_gen_only_exclude:
                                        ['Generate only Exclude parameters and not Max',
                                         'when running --auto-gen-config, except if the',
                                         'number of files with offenses is bigger than',
                                         'exclude-limit. Default is false.'],
      exclude_limit:                    ['Set the limit for how many files to explicitly exclude.',
                                         'If there are more files than the limit, the cop will',
                                         "be disabled instead. Default is #{MAX_EXCL}."],
      disable_uncorrectable:            ['Used with --auto-correct to annotate any',
                                         'offenses that do not support autocorrect',
                                         'with `rubocop:todo` comments.'],
      force_exclusion:                  ['Any files excluded by `Exclude` in configuration',
                                         'files will be excluded, even if given explicitly',
                                         'as arguments.'],
      only_recognized_file_types:       ['Inspect files given on the command line only if',
                                         'they are listed in `AllCops/Include` parameters',
                                         'of user configuration or default configuration.'],
      ignore_disable_comments:          ['Run cops even when they are disabled locally',
                                         'by a `rubocop:disable` directive.'],
      ignore_parent_exclusion:          ['Prevent from inheriting `AllCops/Exclude` from',
                                         'parent folders.'],
      force_default_config:             ['Use default configuration even if configuration',
                                         'files are present in the directory tree.'],
      format:                           ['Choose an output formatter. This option',
                                         'can be specified multiple times to enable',
                                         'multiple formatters at the same time.',
                                         *FORMATTER_OPTION_LIST.map do |item|
                                           "  #{item}#{' (default)' if item == '[p]rogress'}"
                                         end,
                                         '  custom formatter class name'],
      out:                              ['Write output to a file instead of STDOUT.',
                                         'This option applies to the previously',
                                         'specified --format, or the default format',
                                         'if no format is specified.'],
      fail_level:                       ['Minimum severity for exit with error code.',
                                         '  [A] autocorrect',
                                         '  [I] info',
                                         '  [R] refactor',
                                         '  [C] convention',
                                         '  [W] warning',
                                         '  [E] error',
                                         '  [F] fatal'],
      display_time:                     'Display elapsed time in seconds.',
      display_only_failed:              ['Only output offense messages. Omit passing',
                                         'cops. Only valid for --format junit.'],
      display_only_fail_level_offenses:
                                        ['Only output offense messages at',
                                         'the specified --fail-level or above'],
      show_cops:                        ['Shows the given cops, or all cops by',
                                         'default, and their configurations for the',
                                         'current directory.'],
      show_docs_url:                    ['Display url to documentation for the given',
                                         'cops, or base url by default.'],
      fail_fast:                        ['Inspect files in order of modification',
                                         'time and stop after the first file',
                                         'containing offenses.'],
      cache:                            ["Use result caching (FLAG=true) or don't",
                                         '(FLAG=false), default determined by',
                                         'configuration parameter AllCops: UseCache.'],
      cache_root:                       ['Set the cache root directory.',
                                         'Takes precedence over the configuration',
                                         'parameter AllCops: CacheRootDirectory and',
                                         'the $RUBOCOP_CACHE_ROOT environment variable.'],
      debug:                            'Display debug info.',
      display_cop_names:                ['Display cop names in offense messages.',
                                         'Default is true.'],
      disable_pending_cops:             'Run without pending cops.',
      display_style_guide:              'Display style guide URLs in offense messages.',
      enable_pending_cops:              'Run with pending cops.',
      extra_details:                    'Display extra details in offense messages.',
      lint:                             'Run only lint cops.',
      safe:                             'Run only safe cops.',
      stderr:                           ['Write all output to stderr except for the',
                                         'autocorrected source. This is especially useful',
                                         'when combined with --auto-correct and --stdin.'],
      list_target_files:                'List all files RuboCop will inspect.',
      auto_correct:                     'Auto-correct offenses (only when it\'s safe).',
      safe_auto_correct:                '(same, deprecated)',
      auto_correct_all:                 'Auto-correct offenses (safe and unsafe)',
      fix_layout:                       'Run only layout cops, with auto-correct on.',
      color:                            'Force color output on or off.',
      version:                          'Display version.',
      verbose_version:                  'Display verbose version.',
      parallel:                         ['Use available CPUs to execute inspection in',
                                         'parallel. Default is true.'],
      stdin:                            ['Pipe source from STDIN, using FILE in offense',
                                         'reports. This is useful for editor integration.'],
      init:                             'Generate a .rubocop.yml file in the current directory.'
    }.freeze
  end
end
