# encoding: utf-8

require 'optparse'
require 'yaml'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run(args = ARGV)
      $options = { mode: :default }

      OptionParser.new do |opts|
        opts.banner = 'Usage: rubocop [options] [file1, file2, ...]'

        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          $options[:verbose] = v
        end
        opts.on('-e', '--emacs', 'Emacs style output') do
          $options[:mode] = :emacs_style
        end
        opts.on('-c FILE', '--config FILE', 'Configuration file') do |f|
          $options[:config] = YAML.load_file(f)
        end
      end.parse!(args)

      cops = Cop::Cop.all
      show_cops_on_duty(cops) if $options[:verbose]
      total_offences = 0
      @configs = {}

      target_files(args).each do |file|
        report = Report.create(file, $options[:mode])
        source = File.readlines(file).map do |line|
          get_rid_of_invalid_byte_sequences(line)
          line.chomp
        end

        tokens, sexp, correlations = CLI.rip_source(source)

        cops.each do |cop_klass|
          config = $options[:config] || config_from_dotfile(File.dirname(file))
          cop_config = config[cop_klass.name.split('::').last] if config
          if cop_config.nil? || cop_config['Enabled']
            cop = cop_klass.new
            cop.correlations = correlations
            cop.inspect(file, source, tokens, sexp)
            total_offences += cop.offences.count
            report << cop if cop.has_report?
          end
        end

        report.display unless report.empty?
      end

      print "\n#{target_files(args).count} files inspected, "
      puts "#{total_offences} offences detected"

      return total_offences == 0 ? 0 : 1
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
      # @configs is a cache that maps directories to
      # configurations. We search for .rubocop.yml only if we haven't
      # already found it for the given directory.
      unless @configs[target_file_dir]
        dir = target_file_dir
        while dir != '/'
          path = File.join(dir, '.rubocop.yml')
          if File.exist?(path)
            @configs[target_file_dir] = YAML.load_file(path)
            break
          end
          dir = File.expand_path('..', dir)
        end
        path = File.join(Dir.home, '.rubocop.yml')
        @configs[target_file_dir] = YAML.load_file(path) if File.exist?(path)
      end
      @configs[target_file_dir]
    end

    def show_cops_on_duty(cops)
      puts 'Reporting for duty:'
      cops.each { |c| puts c }
      puts '*******************'
    end

    # Generate a list of target files by expanding globing patterns
    # (if any). If args is empty recursively finds all Ruby source
    # files in the current directory
    # @return [Array] array of filenames
    def target_files(args)
      return Dir['**/*.rb'] if args.empty?

      files = []

      args.each do |target|
        if File.directory?(target)
          files << Dir["#{target}/**/*.rb"]
        elsif target =~ /\*/
          files << Dir[target]
        else
          files << target
        end
      end

      files.flatten
    end
  end
end
