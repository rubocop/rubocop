# frozen_string_literal: true

module RuboCop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    STATUS_SUCCESS     = 0
    STATUS_OFFENSES    = 1
    STATUS_ERROR       = 2
    STATUS_INTERRUPTED = 128 + Signal.list['INT']
    DEFAULT_PARALLEL_OPTIONS = %i[
      color debug display_style_guide display_time display_only_fail_level_offenses
      display_only_failed except extra_details fail_level fix_layout format
      ignore_disable_comments lint only only_guide_cops require safe
    ].freeze

    class Finished < StandardError; end

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
      @env = Environment.new(@options, @config_store, paths)

      if @options[:init]
        run_command(:init)
      else
        act_on_options
        validate_options_vs_config
        parallel_by_default!
        apply_default_formatter
        execute_runners
      end
    rescue ConfigNotFoundError, IncorrectCopNameError, OptionArgumentError => e
      warn e.message
      STATUS_ERROR
    rescue RuboCop::Error => e
      warn Rainbow("Error: #{e.message}").red
      STATUS_ERROR
    rescue Finished
      STATUS_SUCCESS
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

    private

    def run_command(name)
      @env.run(name)
    end

    def execute_runners
      if @options[:auto_gen_config]
        run_command(:auto_gen_config)
      else
        run_command(:execute_runner).tap { suggest_extensions }
      end
    end

    def suggest_extensions
      run_command(:suggest_extensions)
    end

    def validate_options_vs_config
      return unless @options[:parallel] && !@config_store.for_pwd.for_all_cops['UseCache']

      raise OptionArgumentError, '-P/--parallel uses caching to speed up execution, so combining ' \
                                 'with AllCops: UseCache: false is not allowed.'
    end

    def parallel_by_default!
      # See https://github.com/rubocop/rubocop/pull/4537 for JRuby and Windows constraints.
      return if RUBY_ENGINE != 'ruby' || RuboCop::Platform.windows?

      if (@options.keys - DEFAULT_PARALLEL_OPTIONS).empty? &&
         @config_store.for_pwd.for_all_cops['UseCache'] != false
        puts 'Use parallel by default.' if @options[:debug]

        @options[:parallel] = true
      end
    end

    def act_on_options
      set_options_to_config_loader

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

    def set_options_to_config_loader
      ConfigLoader.debug = @options[:debug]
      ConfigLoader.disable_pending_cops = @options[:disable_pending_cops]
      ConfigLoader.enable_pending_cops = @options[:enable_pending_cops]
      ConfigLoader.ignore_parent_exclusion = @options[:ignore_parent_exclusion]
    end

    def handle_exiting_options
      return unless Options::EXITING_OPTIONS.any? { |o| @options.key? o }

      run_command(:version) if @options[:version] || @options[:verbose_version]
      run_command(:show_cops) if @options[:show_cops]
      run_command(:show_docs_url) if @options[:show_docs_url]
      raise Finished
    end

    def apply_default_formatter
      # This must be done after the options have already been processed,
      # because they can affect how ConfigStore behaves
      @options[:formatters] ||= begin
        if @options[:auto_gen_config]
          formatter = 'autogenconf'
        else
          cfg = @config_store.for_pwd.for_all_cops
          formatter = cfg['DefaultFormatter'] || 'progress'
        end
        [[formatter, @options[:output_path]]]
      end
    end
  end
end
