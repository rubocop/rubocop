# encoding: utf-8

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    attr_reader :options, :config_store

    alias_method :wants_to_quit?, :wants_to_quit

    def initialize
      @options = {}
      @config_store = ConfigStore.new
    end

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      trap_interrupt

      @options, remaining_args = Options.new.parse(args)
      act_on_options(remaining_args)
      target_files = target_finder.find(remaining_args)

      inspector = FileInspector.new(@options)
      any_failed = inspector.process_files(target_files, @config_store) do
        wants_to_quit?
      end
      inspector.display_error_summary

      !any_failed && !wants_to_quit ? 0 : 1
    rescue => e
      $stderr.puts e.message
      return 1
    end

    def trap_interrupt
      Signal.trap('INT') do
        exit!(1) if wants_to_quit?
        self.wants_to_quit = true
        $stderr.puts
        $stderr.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    private

    def act_on_options(args)
      if @options[:show_cops]
        print_available_cops
        exit(0)
      end

      ConfigLoader.debug = @options[:debug]
      ConfigLoader.auto_gen_config = @options[:auto_gen_config]

      @config_store.options_config = @options[:config] if @options[:config]

      Rainbow.enabled = false unless @options[:color]

      puts Rubocop::Version.version(false) if @options[:version]
      puts Rubocop::Version.version(true) if @options[:verbose_version]
      exit(0) if @options[:version] || @options[:verbose_version]
    end

    def print_available_cops
      cops = Cop::Cop.all
      show_all = @options[:show_cops].empty?

      if show_all
        puts "# Available cops (#{cops.length}) + config for #{Dir.pwd.to_s}: "
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
        cnf = @config_store.for(Dir.pwd.to_s).for_cop(cop)
        puts cnf.to_yaml.lines.to_a[1..-1].map { |line| '  ' + line }
        puts
      end
    end

    def target_finder
      @target_finder ||= TargetFinder.new(@config_store, @options[:debug])
    end
  end
end
