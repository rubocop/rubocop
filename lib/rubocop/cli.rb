# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    include Formatter::TextUtil

    class Finished < Exception; end

    attr_reader :options, :config_store

    def initialize
      @options = {}
      @config_store = ConfigStore.new
    end

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      @options, paths = Options.new.parse(args)
      act_on_options
      apply_default_formatter

      runner = Runner.new(@options, @config_store)
      trap_interrupt(runner)
      all_passed = runner.run(paths)
      display_warning_summary(runner.warnings)
      display_error_summary(runner.errors)
      maybe_print_corrected_source

      all_passed && !runner.aborting? && runner.errors.empty? ? 0 : 1
    rescue RuboCop::Error => e
      $stderr.puts Rainbow("Error: #{e.message}").red
      return 2
    rescue Finished
      return 0
    rescue StandardError, SyntaxError => e
      $stderr.puts e.message
      $stderr.puts e.backtrace
      return 2
    end

    def trap_interrupt(runner)
      Signal.trap('INT') do
        exit!(1) if runner.aborting?
        runner.abort
        $stderr.puts
        $stderr.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    private

    def act_on_options
      handle_exiting_options

      ConfigLoader.debug = @options[:debug]
      ConfigLoader.auto_gen_config = @options[:auto_gen_config]

      @config_store.options_config = @options[:config] if @options[:config]

      if @options[:color]
        # color output explicitly forced on
        Rainbow.enabled = true
      elsif @options[:color] == false
        # color output explicitly forced off
        Rainbow.enabled = false
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
        cfg = @config_store.for(Dir.pwd).for_all_cops
        formatter = cfg['DefaultFormatter'] || 'progress'
        [[formatter, @options[:output_path]]]
      end

      if @options[:auto_gen_config]
        @options[:formatters] << [Formatter::DisabledConfigFormatter,
                                  ConfigLoader::AUTO_GENERATED_FILE]
      end
    end

    def print_available_cops
      cops = Cop::Cop.all
      show_all = @options[:show_cops].empty?

      if show_all
        puts "# Available cops (#{cops.length}) + config for #{Dir.pwd}: "
      end

      cops.types.sort!.each { |type| print_cops_of_type(cops, type, show_all) }
    end

    def print_cops_of_type(cops, type, show_all)
      cops_of_this_type = cops.with_type(type).sort_by!(&:cop_name)

      if show_all
        puts "# Type '#{type.to_s.capitalize}' (#{cops_of_this_type.size}):"
      end

      selected_cops = cops_of_this_type.select do |cop|
        show_all || @options[:show_cops].include?(cop.cop_name)
      end

      selected_cops.each do |cop|
        puts '# Supports --auto-correct' if cop.new.support_autocorrect?
        puts "#{cop.cop_name}:"
        cnf = @config_store.for(Dir.pwd).for_cop(cop)
        puts cnf.to_yaml.lines.to_a.butfirst.map { |line| '  ' + line }
        puts
      end
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

      warn <<-END.strip_indent
        Errors are usually caused by RuboCop bugs.
        Please, report your problems to RuboCop's issue tracker.
        Mention the following information in the issue report:
        #{RuboCop::Version.version(true)}
      END
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
