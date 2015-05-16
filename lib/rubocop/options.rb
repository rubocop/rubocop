# encoding: utf-8

require 'optparse'

module RuboCop
  # This module contains help texts for command line options.
  module OptionsHelp
    TEXT = {
      only:                 'Run only the given cop(s).',
      only_guide_cops:     ['Run only cops for rules that link to a',
                            'style guide.'],
      except:               'Disable the given cop(s).',
      require:              'Require Ruby file.',
      config:               'Specify configuration file.',
      auto_gen_config:     ['Generate a configuration file acting as a',
                            'TODO list.'],
      force_exclusion:     ['Force excluding files specified in the',
                            'configuration `Exclude` even if they are',
                            'explicitly passed as arguments.'],
      format:              ['Choose an output formatter. This option',
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
                            '  custom formatter class name'],
      out:                 ['Write output to a file instead of STDOUT.',
                            'This option applies to the previously',
                            'specified --format, or the default format',
                            'if no format is specified.'],
      fail_level:          ['Minimum severity (A/R/C/W/E/F) for exit',
                            'with error code.'],
      show_cops:           ['Shows the given cops, or all cops by',
                            'default, and their configurations for the',
                            'current directory.'],
      fail_fast:           ['Inspect files in order of modification',
                            'time and stop after the first file',
                            'containing offenses.'],
      debug:                'Display debug info.',
      display_cop_names:    'Display cop names in offense messages.',
      display_style_guide:  'Display style guide URLs in offense messages.',
      rails:                'Run extra Rails cops.',
      lint:                 'Run only lint cops.',
      auto_correct:         'Auto-correct offenses.',
      no_color:             'Disable color output.',
      version:              'Display version.',
      verbose_version:      'Display verbose version.'
    }
  end

  # This class handles command line options.
  class Options
    DEFAULT_FORMATTER = 'progress'
    EXITING_OPTIONS = [:version, :verbose_version, :show_cops]

    def initialize
      @options = {}
    end

    def parse(args)
      define_options(args).parse!(args)

      validate_compatibility

      [@options, args]
    end

    # Cop name validation must be done later than option parsing, so it's not
    # called from within this class.
    def self.validate_cop_list(names)
      return unless names

      namespaces = Cop::Cop.all.types.map { |t| t.to_s.capitalize }
      names.each do |name|
        next if Cop::Cop.all.any? { |c| c.cop_name == name } ||
                namespaces.include?(name)
        fail ArgumentError, "Unrecognized cop or namespace: #{name}."
      end
    end

    private

    def define_options(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        add_only_options(opts)
        add_configuration_options(opts, args)
        add_formatting_options(opts)

        option(opts, '-r', '--require FILE') { |f| require f }

        add_severity_option(opts)
        add_flags_with_optional_args(opts)
        add_boolean_flags(opts)
      end
    end

    def validate_compatibility
      if @options.key?(:only) &&
         (@options[:only] & %w(Lint/UnneededDisable UnneededDisable)).any?
        fail ArgumentError, 'Lint/UnneededDisable can not be used with --only.'
      end
      return unless (incompat = @options.keys & EXITING_OPTIONS).size > 1
      fail ArgumentError, "Incompatible cli options: #{incompat.inspect}"
    end

    def add_only_options(opts)
      add_cop_selection_csv_option('except', opts)
      add_cop_selection_csv_option('only', opts)
      option(opts, '--only-guide-cops')
    end

    def add_cop_selection_csv_option(option, opts)
      option(opts, "--#{option} [COP1,COP2,...]") do |list|
        @options[:"#{option}"] = list.split(',').map do |c|
          Cop::Cop.qualified_cop_name(c, "--#{option} option")
        end
      end
    end

    def add_configuration_options(opts, args)
      option(opts, '-c', '--config FILE')

      option(opts, '--auto-gen-config') do
        validate_auto_gen_config_option(args)
        @options[:formatters] = [[DEFAULT_FORMATTER],
                                 [Formatter::DisabledConfigFormatter,
                                  ConfigLoader::AUTO_GENERATED_FILE]]
      end

      option(opts, '--force-exclusion')
    end

    def add_formatting_options(opts)
      option(opts, '-f', '--format FORMATTER') do |key|
        @options[:formatters] ||= []
        @options[:formatters] << [key]
      end

      option(opts, '-o', '--out FILE') do |path|
        @options[:formatters] ||= [[DEFAULT_FORMATTER]]
        @options[:formatters].last << path
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

    def add_boolean_flags(opts)
      option(opts, '-F', '--fail-fast')
      option(opts, '-d', '--debug')
      option(opts, '-D', '--display-cop-names')
      option(opts, '-S', '--display-style-guide')
      option(opts, '-R', '--rails')
      option(opts, '-l', '--lint')
      option(opts, '-a', '--auto-correct')

      @options[:color] = true
      option(opts, '-n', '--no-color') { @options[:color] = false }

      option(opts, '-v', '--version')
      option(opts, '-V', '--verbose-version')
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
      long_opt[2..-1].sub(/ .*/, '').gsub(/-/, '_').to_sym
    end

    def validate_auto_gen_config_option(args)
      return unless args.any?

      warn '--auto-gen-config can not be combined with any other arguments.'
      exit(1)
    end
  end
end
