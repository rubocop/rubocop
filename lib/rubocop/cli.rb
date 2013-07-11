# encoding: utf-8
require 'pathname'
require 'optparse'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    DEFAULT_FORMATTER = 'progress'

    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    attr_accessor :options

    alias_method :wants_to_quit?, :wants_to_quit

    def initialize
      @cops = Cop::Cop.all
      @errors = []
      @options = {}
      @config_store = ConfigStore.new
    end

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      trap_interrupt

      begin
        parse_options(args)
      rescue => e
        $stderr.puts e.message
        return 1
      end

      # filter out Rails cops unless requested
      @cops.reject!(&:rails?) unless @options[:rails]

      # filter out style cops when --lint is passed
      @cops.select!(&:lint?) if @options[:lint]

      target_files = target_finder.target_files(args)
      target_files.each(&:freeze).freeze
      inspected_files = []
      any_failed = false

      formatter_set.started(target_files)

      target_files.each do |file|
        break if wants_to_quit?

        puts "Scanning #{file}" if @options[:debug]
        formatter_set.file_started(file, {})

        offences = inspect_file(file)

        any_failed = true unless offences.empty?
        inspected_files << file
        formatter_set.file_finished(file, offences.freeze)
      end

      formatter_set.finished(inspected_files.freeze)
      formatter_set.close_output_files

      display_error_summary(@errors) unless @options[:silent]

      !any_failed && !wants_to_quit ? 0 : 1
    end

    def validate_only_option
      if @cops.none? { |c| c.cop_name == @options[:only] }
        fail ArgumentError, "Unrecognized cop name: #{@options[:only]}."
      end
    end

    def inspect_file(file)
      begin
        ast, comments, tokens, source_buffer, source, syntax_offences =
          CLI.parse(file) { |sb| sb.read }

      rescue Encoding::UndefinedConversionError, ArgumentError => e
        handle_error(e, "An error occurred while parsing #{file}.".color(:red))
        return []
      end

      # If we got any syntax errors, return only the syntax offences.
      # Parser may return nil for AST even though there are no syntax errors.
      # e.g. sources which contain only comments
      return syntax_offences unless syntax_offences.empty?

      config = @config_store.for(file)
      disabled_lines = disabled_lines_in(source)

      set_config_for_all_cops(config)

      @cops.reduce([]) do |offences, cop_class|
        cop_name = cop_class.cop_name
        if config.cop_enabled?(cop_name)
          cop = setup_cop(cop_class, disabled_lines)
          if !@options[:only] || @options[:only] == cop_name
            begin
              cop.inspect(source_buffer, source, tokens, ast, comments)
            rescue => e
              handle_error(e,
                           "An error occurred while #{cop.name}".color(:red) +
                           " cop was inspecting #{file}.".color(:red))
            end
          end
          offences.concat(cop.offences)
        end
        offences
      end.sort
    end

    def set_config_for_all_cops(config)
      @cops.each do |cop_class|
        cop_class.config = config.for_cop(cop_class.cop_name)
      end
    end

    def setup_cop(cop_class, disabled_lines = nil)
      cop = cop_class.new
      cop.debug = @options[:debug]
      cop.autocorrect = @options[:autocorrect]
      cop.disabled_lines = disabled_lines[cop_class.cop_name] if disabled_lines
      cop
    end

    def handle_error(e, message)
      @errors << message
      warn message
      if @options[:debug]
        puts e.message, e.backtrace
      else
        warn 'To see the complete backtrace run rubocop -d.'
      end
    end

    # rubocop:disable MethodLength
    def parse_options(args)
      convert_deprecated_options!(args)

      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        opts.on('-d', '--debug', 'Display debug info.') do |d|
          @options[:debug] = d
        end
        opts.on('-c', '--config FILE', 'Specify configuration file.') do |f|
          @options[:config] = f
          @config_store.set_options_config(@options[:config])
        end
        opts.on('--only COP', 'Run just one cop.') do |s|
          @options[:only] = s
          validate_only_option
        end
        opts.on('-f', '--format FORMATTER',
                'Choose an output formatter. This option',
                'can be specified multiple times to enable',
                'multiple formatters at the same time.',
                '  [p]rogress (default)',
                '  [s]imple',
                '  [c]lang',
                '  [e]macs',
                '  [j]son',
                '  custom formatter class name') do |key|
          @options[:formatters] ||= []
          @options[:formatters] << [key]
        end
        opts.on('-o', '--out FILE',
                'Write output to a file instead of STDOUT.',
                'This option applies to the previously',
                'specified --format, or the default format',
                'if no format is specified.') do |path|
          @options[:formatters] ||= [[DEFAULT_FORMATTER]]
          @options[:formatters].last << path
        end
        opts.on('-r', '--require FILE', 'Require Ruby file.') do |f|
          require f
        end
        opts.on('-R', '--rails', 'Run extra Rails cops.') do |r|
          @options[:rails] = r
        end
        opts.on('-l', '--lint', 'Run only lint cops.') do |l|
          @options[:lint] = l
        end
        opts.on('-a', '--auto-correct', 'Auto-correct offences.') do |a|
          @options[:autocorrect] = a
        end
        opts.on('-s', '--silent', 'Silence summary.') do |s|
          @options[:silent] = s
        end
        opts.on('-n', '--no-color', 'Disable color output.') do |s|
          Sickill::Rainbow.enabled = false
        end
        opts.on('-v', '--version', 'Display version.') do
          puts Rubocop::Version.version(false)
          exit(0)
        end
        opts.on('-V', '--verbose-version', 'Display verbose version.') do
          puts Rubocop::Version.version(true)
          exit(0)
        end
      end.parse!(args)
    end
    # rubocop:enable MethodLength

    def convert_deprecated_options!(args)
      args.map! do |arg|
        case arg
        when '-e', '--emacs'
          deprecate("#{arg} option", '--format emacs', '1.0.0')
          %w(--format emacs)
        else
          arg
        end
      end.flatten!
    end

    def trap_interrupt
      Signal.trap('INT') do
        exit!(1) if wants_to_quit?
        self.wants_to_quit = true
        $stderr.puts
        $stderr.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    def display_error_summary(errors)
      return if errors.empty?
      plural = errors.count > 1 ? 's' : ''
      puts "\n#{errors.count} error#{plural} occurred:".color(:red)
      errors.each { |error| puts error }
      puts 'Errors are usually caused by RuboCop bugs.'
      puts 'Please, report your problems to RuboCop\'s issue tracker.'
      puts 'Mention the following information in the issue report:'
      puts Rubocop::Version.version(true)
    end

    def disabled_lines_in(source)
      disabled_lines = Hash.new([])
      disabled_section = {}
      regexp = '# rubocop : (%s)\b ((?:\w+,? )+)'.gsub(' ', '\s*')
      section_regexp = '^\s*' + sprintf(regexp, '(?:dis|en)able')
      single_line_regexp = '\S.*' + sprintf(regexp, 'disable')

      source.each_with_index do |line, ix|
        each_mentioned_cop(/#{section_regexp}/, line) do |cop_name, kind|
          disabled_section[cop_name] = (kind == 'disable')
        end
        disabled_section.keys.each do |cop_name|
          disabled_lines[cop_name] += [ix + 1] if disabled_section[cop_name]
        end

        each_mentioned_cop(/#{single_line_regexp}/, line) do |cop_name, kind|
          disabled_lines[cop_name] += [ix + 1] if kind == 'disable'
        end
      end
      disabled_lines
    end

    def each_mentioned_cop(regexp, line)
      match = line.match(regexp)
      if match
        kind, cops = match.captures
        cops = Cop::Cop.all.map(&:cop_name).join(',') if cops.include?('all')
        cops.split(/,\s*/).each { |cop_name| yield cop_name, kind }
      end
    end

    def self.parse(file)
      parser = Parser::CurrentRuby.new

      # On JRuby and Rubinius, there's a risk that we hang in
      # tokenize() if we don't set the all errors as fatal flag.
      parser.diagnostics.all_errors_are_fatal = RUBY_ENGINE != 'ruby'
      parser.diagnostics.ignore_warnings      = false

      diagnostics = []
      parser.diagnostics.consumer = lambda do |diagnostic|
        diagnostics << diagnostic
      end

      source_buffer = Parser::Source::Buffer.new(file, 1)
      yield source_buffer

      begin
        ast, comments, tokens = parser.tokenize(source_buffer)
      rescue Parser::SyntaxError # rubocop:disable HandleExceptions
        # All errors are in diagnostics. No need to handle exception.
      end

      if tokens
        tokens = tokens.map do |t|
          type, details = *t
          text, range = *details
          Rubocop::Cop::Token.new(range, type, text)
        end
      end

      syntax_offences = diagnostics.map do |d|
        Cop::Offence.new(d.level, d.location, "#{d.message}",
                         'Syntax')
      end

      source = source_buffer.source.split($RS)

      [ast, comments, tokens, source_buffer, source, syntax_offences]
    end

    private

    def target_finder
      @target_finder ||= TargetFinder.new(@config_store, @options[:debug])
    end

    def formatter_set
      @formatter_set ||= begin
        set = Formatter::FormatterSet.new(!@options[:silent])
        pairs = @options[:formatters] || [[DEFAULT_FORMATTER]]
        pairs.each do |formatter_key, output_path|
          set.add_formatter(formatter_key, output_path)
        end
        set
      rescue => error
        warn error.message
        exit(1)
      end
    end

    def deprecate(subject, alternative = nil, version = nil)
      message =  "#{subject} is deprecated"
      message << " and will be removed in RuboCop #{version}" if version
      message << '.'
      message << " Please use #{alternative} instead." if alternative
      warn message
    end
  end
end
