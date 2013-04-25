# encoding: utf-8

require 'optparse'
require 'yaml'
require_relative 'cop/grammar'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    # If set true while running,
    # RuboCop will abort processing and exit gracefully.
    attr_accessor :wants_to_quit
    alias_method :wants_to_quit?, :wants_to_quit

    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      trap_interrupt

      $options = { mode: :default }

      parse_options(args)

      cops = Cop::Cop.all
      show_cops_on_duty(cops) if $options[:debug]
      processed_file_count = 0
      total_offences = 0
      errors_count = 0
      @configs = {}

      target_files(args).each do |file|
        break if wants_to_quit?

        puts "Scanning #{file}" if $options[:debug]

        report = Report.create(file, $options[:mode])
        source = File.readlines(file).map do |line|
          get_rid_of_invalid_byte_sequences(line)
          line.chomp
        end

        syntax_cop = Rubocop::Cop::Syntax.new
        syntax_cop.inspect(file, source, nil, nil)

        if syntax_cop.offences.map(&:severity).include?(:error)
          # In case of a syntax error we just report that error and do
          # no more checking in the file.
          report << syntax_cop
          total_offences += syntax_cop.offences.count
        else
          tokens, sexp, correlations = CLI.rip_source(source)
          config = $options[:config] || config_from_dotfile(File.dirname(file))
          disabled_lines = disabled_lines_in(source)

          cops.each do |cop_klass|
            cop_name = cop_klass.name.split('::').last
            cop_config = config[cop_name] if config
            if cop_config.nil? || cop_config['Enabled']
              cop_klass.config = cop_config
              cop = cop_klass.new
              cop.correlations = correlations
              cop.disabled_lines = disabled_lines[cop_name]
              begin
                cop.inspect(file, source, tokens, sexp)
              rescue => e
                errors_count += 1
                warn "An error occurred while #{cop} was inspecting #{file}."
                warn "To see the complete backtrace run rubocop -d."
                puts e.backtrace if $options[:debug]
              end
              total_offences += cop.offences.count
              report << cop if cop.has_report?
            end
          end
        end

        processed_file_count += 1
        report.display unless report.empty?
      end

      unless $options[:silent]
        display_summary(processed_file_count, total_offences, errors_count)
      end

      (total_offences == 0) && !wants_to_quit ? 0 : 1
    end

    def parse_options(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        opts.on('-d', '--[no-]debug', 'Display debug info') do |d|
          $options[:debug] = d
        end
        opts.on('-e', '--emacs', 'Emacs style output') do
          $options[:mode] = :emacs_style
        end
        opts.on('-c FILE', '--config FILE', 'Configuration file') do |f|
          $options[:config] = YAML.load_file(f)
        end
        opts.on('-s', '--silent', 'Silence summary') do |s|
          $options[:silent] = s
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
        STDERR.puts
        STDERR.puts 'Exiting... Interrupt again to exit immediately.'
      end
    end

    def display_summary(num_files, total_offences, errors_count)
      print "\n#{num_files} file#{num_files > 1 ? 's' : ''} inspected, "
      offences_string = if total_offences.zero?
                          'no offences'
                        elsif total_offences == 1
                          '1 offence'
                        else
                          "#{total_offences} offences"
                        end
      puts "#{offences_string} detected"
        .send(total_offences.zero? ? :green : :red)

      if errors_count > 0
        plural = errors_count > 1 ? 's' : ''
        puts "\n#{errors_count} error#{plural} occurred.".red
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
        if cops.include?('all')
          cops = Cop::Cop.all.map { |c| c.name.split('::').last }.join(',')
        end
        cops.split(/,\s*/).each { |cop_name| yield cop_name, kind }
      end
    end

    def get_rid_of_invalid_byte_sequences(line)
      enc = line.encoding.name
      # UTF-16 works better in this algorithm but is not supported in 1.9.2.
      temporary_encoding = (RUBY_VERSION == '1.9.2') ? 'UTF-8' : 'UTF-16'
      line.encode!(temporary_encoding, enc, invalid: :replace, replace: '')
      line.encode!(enc, temporary_encoding)
    end

    def self.rip_source(source)
      tokens = Ripper.lex(source.join("\n")).map { |t| Cop::Token.new(*t) }
      sexp = Ripper.sexp(source.join("\n"))
      Cop::Position.make_position_objects(sexp)
      correlations = Cop::Grammar.new(tokens).correlate(sexp)
      [tokens, sexp, correlations]
    end

    # Returns the configuration hash from .rubocop.yml searching
    # upwards in the directory structure starting at the given
    # directory where the inspected file is. If no .rubocop.yml is
    # found there, the user's home directory is checked.
    def config_from_dotfile(target_file_dir)
      return unless target_file_dir
      # @configs is a cache that maps directories to
      # configurations. We search for .rubocop.yml only if we haven't
      # already found it for the given directory.
      unless @configs[target_file_dir]
        dir = target_file_dir
        while dir != '/'
          path = File.join(dir, '.rubocop.yml')
          if File.exist?(path)
            @configs[target_file_dir] = YAML.load_file(path)
            return @configs[target_file_dir]
          end
          dir = File.expand_path('..', dir)
        end
        path = File.join(Dir.home, '.rubocop.yml')
        @configs[target_file_dir] = YAML.load_file(path) if File.exist?(path)
      end
      @configs[target_file_dir]
    end

    def cops_on_duty(config)
      cops_on_duty = []

      Cop::Cop.all.each do |cop_klass|
        cop_config = config[cop_klass.name.split('::').last] if config
        cops_on_duty << cop_klass if cop_config.nil? || cop_config['Enabled']
      end

      cops_on_duty
    end

    def show_cops_on_duty(cops)
      puts '== Reporting for duty =='
      cops.each { |c| puts ' * '.yellow + c.to_s.green }
      puts '========================'
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
          files << ruby_files(target)
        elsif target =~ /\*/
          files << Dir[target]
        else
          files << target
        end
      end

      files.flatten
    end

    # Finds all Ruby source files under the current or other supplied
    # directory.  A Ruby source file is defined as a file with the `.rb`
    # extension or a file with no extension that has a ruby shebang line
    # as its first line.
    # @param root Root directory under which to search for ruby source files
    # @return [Array] Array of filenames
    def ruby_files(root = Dir.pwd)
      files = Dir["#{root}/**/*"].reject { |file| FileTest.directory? file }

      rb = []

      rb << files.select { |file| File.extname(file) == '.rb' }
      rb << files.select do |file|
        File.extname(file) == '' &&
        begin
          File.open(file) { |f| f.readline } =~ /#!.*ruby/
        rescue EOFError, ArgumentError => e
          log_error(e, "Unprocessable file #{file.inspect}: ")
          false
        end
      end

      rb.flatten
    end

    private

    def log_error(e, msg='')
      if $options[:debug]
        error_message = "#{e.class}, #{e.message}"
        STDERR.puts "#{msg}\t#{error_message}"
      end
    end
  end
end
