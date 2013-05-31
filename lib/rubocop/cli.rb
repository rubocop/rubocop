# encoding: utf-8
require 'pathname'
require 'optparse'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    BUILTIN_FORMATTERS_FOR_KEYS = {
      'plain' => Formatter::PlainTextFormatter,
      'emacs' => Formatter::EmacsStyleFormatter
    }

    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    attr_accessor :options

    alias_method :wants_to_quit?, :wants_to_quit

    def initialize
      @cops = Cop::Cop.all
      @errors = []
      @options = {}
      ConfigStore.prepare
    end

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      trap_interrupt

      parse_options(args)

      begin
        validate_only_option if @options[:only]
      rescue ArgumentError => e
        puts e.message
        return 1
      end

      target_files = target_files(args)
      processed_files = []
      any_failed = false

      formatter.started(target_files)

      target_files.each do |file|
        break if wants_to_quit?

        config = ConfigStore.for(file)

        puts "Scanning #{file}" if @options[:debug]
        formatter.file_started(file, {})

        syntax_cop = Rubocop::Cop::Syntax.new
        syntax_cop.debug = @options[:debug]
        syntax_cop.inspect_file(file)

        offences = if syntax_cop.offences.map(&:severity).include?(:error)
                     # In case of a syntax error we just report that error
                     # and do no more checking in the file.
                     syntax_cop.offences
                   else
                     inspect_file(file, config)
                   end

        any_failed = true unless offences.empty?
        processed_files << file
        formatter.file_finished(file, offences)
      end

      formatter.finished(processed_files)

      display_error_summary(@errors) unless @options[:silent]

      !any_failed && !wants_to_quit ? 0 : 1
    end

    def validate_only_option
      if @cops.none? { |c| c.cop_name == @options[:only] }
        fail ArgumentError, "Unrecognized cop name: #{@options[:only]}."
      end
    end

    def inspect_file(file, config)
      begin
        ast, comments, tokens, source = CLI.parse(file) do |source_buffer|
          source_buffer.read
        end
      rescue Parser::SyntaxError, Encoding::UndefinedConversionError,
        ArgumentError => e
        handle_error(e, "An error occurred while parsing #{file}.".color(:red))
        return []
      end

      disabled_lines = disabled_lines_in(source)

      @cops.reduce([]) do |offences, cop_class|
        cop_name = cop_class.cop_name
        cop_class.config = config.for_cop(cop_name)
        if config.cop_enabled?(cop_name)
          cop = setup_cop(cop_class,
                          disabled_lines)
          if !@options[:only] || @options[:only] == cop_name
            begin
              cop.inspect(source, tokens, ast, comments)
            rescue => e
              handle_error(e,
                           "An error occurred while #{cop.name}".color(:red) +
                           " cop was inspecting #{file}.".color(:red))
            end
          end
          offences.concat(cop.offences)
        end
        offences
      end
    end

    def setup_cop(cop_class, disabled_lines)
      cop = cop_class.new
      cop.debug = @options[:debug]
      cop.disabled_lines = disabled_lines[cop_class.cop_name]
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

        opts.on('-d', '--debug', 'Display debug info') do |d|
          @options[:debug] = d
        end
        opts.on('-c FILE', '--config FILE', 'Configuration file') do |f|
          @options[:config] = f
          ConfigStore.set_options_config(@options[:config])
        end
        opts.on('--only COP', 'Run just one cop') do |s|
          @options[:only] = s
        end
        opts.on('-f', '--format FORMATTER',
                'Choose a formatter',
                '  [p]lain (default)',
                '  [e]macs') do |key|
          @options[:formatter] = key
        end
        opts.on('--require FILE', 'Require Ruby file') do |f|
          require f
        end
        opts.on('-s', '--silent', 'Silence summary') do |s|
          @options[:silent] = s
        end
        opts.on('-n', '--no-color', 'Disable color output') do |s|
          Sickill::Rainbow.enabled = false
        end
        opts.on('-v', '--version', 'Display version') do
          puts Rubocop::Version::STRING
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

      parser.diagnostics.all_errors_are_fatal = true
      parser.diagnostics.ignore_warnings      = true

      parser.diagnostics.consumer = lambda do |diagnostic|
        $stderr.puts(diagnostic.render)
      end

      source_buffer = Parser::Source::Buffer.new(file, 1)
      yield source_buffer

      ast, comments, tokens = parser.tokenize(source_buffer)

      tokens = tokens.map do |t|
        type, details = *t
        text, range = *details
        Rubocop::Cop::Token.new(range, type, text)
      end

      [ast, comments, tokens, source_buffer.source.split($RS)]
    end

    # Generate a list of target files by expanding globing patterns
    # (if any). If args is empty recursively finds all Ruby source
    # files under the current directory
    # @return [Array] array of filenames
    def target_files(args)
      return ruby_files if args.empty?

      files = []

      args.each do |target|
        if File.directory?(target)
          files += ruby_files(target.chomp(File::SEPARATOR))
        elsif target =~ /\*/
          files += Dir[target]
        else
          files << target
        end
      end

      files.uniq
    end

    # Finds all Ruby source files under the current or other supplied
    # directory.  A Ruby source file is defined as a file with the `.rb`
    # extension or a file with no extension that has a ruby shebang line
    # as its first line.
    # It is possible to specify includes and excludes using the config file,
    # so you can include other Ruby files like Rakefiles and gemspecs.
    # @param root Root directory under which to search for ruby source files
    # @return [Array] Array of filenames
    def ruby_files(root = Dir.pwd)
      files = Dir["#{root}/**/*"].reject { |file| FileTest.directory? file }

      rb = []

      rb += files.select { |file| File.extname(file) == '.rb' }
      rb += files.select do |file|
        if File.extname(file) == ''
          begin
            File.open(file) { |f| f.readline } =~ /#!.*ruby/
          rescue EOFError, ArgumentError => e
            log_error(e, "Unprocessable file #{file.inspect}: ")
            false
          end
        end
      end

      rb += files.select do |file|
        config = ConfigStore.for(file)
        config.file_to_include?(file)
      end

      rb.reject do |file|
        config = ConfigStore.for(file)
        config.file_to_exclude?(file)
      end.uniq
    end

    private

    def log_error(e, msg = '')
      if @options[:debug]
        error_message = "#{e.class}, #{e.message}"
        STDERR.puts "#{msg}\t#{error_message}"
      end
    end

    def formatter
      @formatter ||= begin
        key = @options[:formatter] || 'plain'
        formatter_class = builtin_formatter_class(key)
        formatter = formatter_class.new($stdout)
        if formatter.respond_to?(:reports_summary=)
          # TODO: Consider dropping -s/--silent option
          formatter.reports_summary = !@options[:silent]
        end
        formatter
      rescue => error
        warn error.message
        exit(1)
      end
    end

    def builtin_formatter_class(specified_key)
      matching_keys = BUILTIN_FORMATTERS_FOR_KEYS.keys.select do |key|
        key.start_with?(specified_key)
      end

      if matching_keys.empty?
        fail %(No formatter for "#{specified_key}")
      elsif matching_keys.size > 1
        fail %(Cannot determine formatter for "#{specified_key}")
      end

      BUILTIN_FORMATTERS_FOR_KEYS[matching_keys.first]
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
