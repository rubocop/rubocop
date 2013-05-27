# encoding: utf-8
require 'pathname'
require 'optparse'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    attr_accessor :options

    alias_method :wants_to_quit?, :wants_to_quit

    def initialize
      @cops = Cop::Cop.all
      @processed_file_count = 0
      @total_offences = 0
      @errors = []
      @options = { mode: :default }
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

      target_files(args).each do |file|
        break if wants_to_quit?

        config = ConfigStore.for(file)
        report = Report.create(file, @options[:mode])
        source = read_source(file)

        puts "Scanning #{file}" if @options[:debug]

        syntax_cop = Rubocop::Cop::Syntax.new
        syntax_cop.debug = @options[:debug]
        syntax_cop.inspect(source, nil, nil, nil)

        if syntax_cop.offences.map(&:severity).include?(:error)
          # In case of a syntax error we just report that error and do
          # no more checking in the file.
          report << syntax_cop
          @total_offences += syntax_cop.offences.count
        else
          inspect_file(file, source, config, report)
        end

        @processed_file_count += 1
        report.display unless report.empty?
      end

      unless @options[:silent]
        display_summary(@processed_file_count, @total_offences, @errors)
      end

      (@total_offences == 0) && !wants_to_quit ? 0 : 1
    end

    def validate_only_option
      if @cops.none? { |c| c.cop_name == @options[:only] }
        fail ArgumentError, "Unrecognized cop name: #{@options[:only]}."
      end
    end

    def read_source(file)
      File.read(file).split($RS)
    end

    def inspect_file(file, source, config, report)
      begin
        ast, comments, tokens = CLI.rip_source(file, source.join("\n"))
      rescue Parser::SyntaxError, Encoding::UndefinedConversionError,
        ArgumentError => e
        handle_error(e, "An error occurred while parsing #{file}.".color(:red))
        return
      end

      disabled_lines = disabled_lines_in(source)

      @cops.each do |cop_class|
        cop_name = cop_class.cop_name
        if config.cop_enabled?(cop_name)
          cop = setup_cop(cop_class,
                          config.for_cop(cop_name),
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
          @total_offences += cop.offences.count
          report << cop if cop.has_report?
        end
      end
    end

    def setup_cop(cop_class, cop_config, disabled_lines)
      cop_class.config = cop_config
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

    def parse_options(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        opts.on('-d', '--debug', 'Display debug info') do |d|
          @options[:debug] = d
        end
        opts.on('-e', '--emacs', 'Emacs style output') do
          @options[:mode] = :emacs_style
        end
        opts.on('-c FILE', '--config FILE', 'Configuration file') do |f|
          @options[:config] = f
          ConfigStore.set_options_config(@options[:config])
        end
        opts.on('--only COP', 'Run just one cop') do |s|
          @options[:only] = s
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

    def trap_interrupt
      Signal.trap('INT') do
        exit!(1) if wants_to_quit?
        self.wants_to_quit = true
        $stderr.puts
        $stderr.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    def display_summary(num_files, total_offences, errors)
      plural = num_files == 0 || num_files > 1 ? 's' : ''
      print "\n#{num_files} file#{plural} inspected, "
      offences_string = if total_offences.zero?
                          'no offences'
                        elsif total_offences == 1
                          '1 offence'
                        else
                          "#{total_offences} offences"
                        end
      puts "#{offences_string} detected"
        .color(total_offences.zero? ? :green : :red)

      if errors.count > 0
        plural = errors.count > 1 ? 's' : ''
        puts "\n#{errors.count} error#{plural} occurred:".color(:red)
        errors.each { |error| puts error }
        puts 'Errors are usually caused by RuboCop bugs.'
        puts 'Please, report your problems to RuboCop\'s issue tracker.'
      end
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

    def self.rip_source(file, source)
      ast, _comments, tokens = parse(file, source)

      tokens = tokens.map do |t|
        type, details = *t
        text, range = *details
        pos = Rubocop::Cop::Position.new(range.line, range.column)
        Rubocop::Cop::Token.new(pos, type, text)
      end

      comments = tokens.select { |t| t.type == :tCOMMENT }

      [ast, comments, tokens]
    end

    def self.parse(file, string)
      parser = Parser::CurrentRuby.new

      parser.diagnostics.all_errors_are_fatal = true
      parser.diagnostics.ignore_warnings      = true

      parser.diagnostics.consumer = lambda do |diagnostic|
        $stderr.puts(diagnostic.render)
      end

      source_buffer = Parser::Source::Buffer.new(file, 1)
      source_buffer.source = string

      parser.tokenize(source_buffer)
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
  end
end
