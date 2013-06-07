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

      begin
        parse_options(args)
      rescue => e
        $stderr.puts e.message
        return 1
      end

      target_files = target_files(args)
      processed_files = []
      any_failed = false

      invoke_formatters(:started, target_files)

      target_files.each do |file|
        break if wants_to_quit?

        puts "Scanning #{file}" if @options[:debug]
        invoke_formatters(:file_started, file, {})

        offences = inspect_file(file)

        any_failed = true unless offences.empty?
        processed_files << file
        invoke_formatters(:file_finished, file, offences)
      end

      invoke_formatters(:finished, processed_files)
      close_output_files

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
        ast, comments, tokens, source, syntax_offences =
          CLI.parse(file) { |source_buffer| source_buffer.read }
      rescue Encoding::UndefinedConversionError, ArgumentError => e
        handle_error(e, "An error occurred while parsing #{file}.".color(:red))
        return []
      end

      # If we got an AST from Parser, it means we can
      # continue. Otherwise, return only the syntax offences.
      return syntax_offences unless ast

      config = ConfigStore.for(file)
      disabled_lines = disabled_lines_in(source)

      @cops.reduce(syntax_offences) do |offences, cop_class|
        cop_name = cop_class.cop_name
        cop_class.config = config.for_cop(cop_name)
        if config.cop_enabled?(cop_name)
          cop = setup_cop(cop_class, disabled_lines)
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

    def setup_cop(cop_class, disabled_lines = nil)
      cop = cop_class.new
      cop.debug = @options[:debug]
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
          ConfigStore.set_options_config(@options[:config])
        end
        opts.on('--only COP', 'Run just one cop.') do |s|
          @options[:only] = s
          validate_only_option
        end
        opts.on('-f', '--format FORMATTER',
                'Choose a formatter.',
                '  [p]lain (default)',
                '  [e]macs',
                '  custom formatter class name') do |key|
          @options[:formatters] ||= []
          @options[:formatters] << [key]
        end
        opts.on('-o', '--out FILE',
                'Write output to a file instead of STDOUT.',
                '  This option applies to the previously',
                '  specified --format, or the default',
                '  format if no format is specified.') do |path|
          @options[:formatters] ||= [['plain']]
          @options[:formatters].last << path
        end
        opts.on('--require FILE', 'Require Ruby file.') do |f|
          require f
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
      parser.diagnostics.ignore_warnings      = true

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
        Cop::Offence.new(:error, d.location, "Syntax error, #{d.message}",
                         'Syntax')
      end

      [ast, comments, tokens, source_buffer.source.split($RS), syntax_offences]
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

      files.map { |f| File.expand_path(f) }.uniq
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

    def invoke_formatters(method, *args)
      formatters.each { |f| f.send(method, *args) }
    end

    def close_output_files
      formatters.each do |formatter|
        formatter.output.close if formatter.output.is_a?(File)
      end
    end

    def formatters
      @formatters ||= begin
        pairs = @options[:formatters] || [['plain']]
        pairs.map do |formatter_key, output_path|
          create_formatter(formatter_key, output_path)
        end
      rescue => error
        warn error.message
        exit(1)
      end
    end

    def create_formatter(formatter_key, output_path = nil)
      formatter_class = if formatter_key =~ /\A[A-Z]/
                          custom_formatter_class(formatter_key)
                        else
                          builtin_formatter_class(formatter_key)
                        end

      output = output_path ? File.open(output_path, 'w') : $stdout

      formatter = formatter_class.new(output)
      if formatter.respond_to?(:reports_summary=)
        # TODO: Consider dropping -s/--silent option
        formatter.reports_summary = !@options[:silent]
      end
      formatter
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

    def custom_formatter_class(specified_class_name)
      constants = specified_class_name.split('::')
      constants.shift if constants.first.empty?
      constants.reduce(Object) do |namespace, constant|
        namespace.const_get(constant, false)
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
