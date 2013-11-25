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

      @config_store.set_options_config(@options[:config]) if @options[:config]

      Sickill::Rainbow.enabled = false if @options[:no_color]

      puts Rubocop::Version.version(false) if @options[:version]
      puts Rubocop::Version.version(true) if @options[:verbose_version]
      exit(0) if @options[:version] || @options[:verbose_version]

      ConfigLoader.debug = @options[:debug]

      if @options[:auto_gen_config]
        target_finder.find(args).each do |file|
          config = @config_store.for(file)
          if config.contains_auto_generated_config
            fail "Remove #{ConfigLoader::AUTO_GENERATED_FILE} from the " +
              'current configuration before generating it again.'
          end
        end
      end
    end

    def print_available_cops
      cops = Cop::Cop.all
      puts "Available cops (#{cops.length}) + config for #{Dir.pwd.to_s}: "
      dirconf = @config_store.for(Dir.pwd.to_s)
      cops.types.sort!.each do |type|
        coptypes = cops.with_type(type).sort_by!(&:cop_name)
        puts "Type '#{type.to_s.capitalize}' (#{coptypes.size}):"
        coptypes.each do |cop|
          puts " - #{cop.cop_name}"
          cnf = dirconf.for_cop(cop).dup
          print_conf_option('Description',
                            cnf.delete('Description') { 'None' })
          cnf.each { |k, v| print_conf_option(k, v) }
          print_conf_option('SupportsAutoCorrection',
                            cop.new.support_autocorrect?.to_s)
        end
      end
    end

    def print_conf_option(option, value)
      puts  "    - #{option}: #{value}"
    end

    def target_finder
      @target_finder ||= TargetFinder.new(@config_store, @options[:debug])
    end
  end
end
