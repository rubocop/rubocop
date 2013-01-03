# encoding: utf-8

require 'optparse'

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
        opts.banner = "Usage: rubocop [options] [file1, file2, ...]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          $options[:verbose] = v
        end
        opts.on("-e", "--emacs", "Emacs style output") do
          $options[:mode] = :emacs_style
        end
      end.parse!(args)

      cops = Cop::Cop.all
      show_cops_on_duty(cops) if $options[:verbose]
      total_offences = 0

      target_files(args).each do |file|
        report = Report.create(file, $options[:mode])
        source = File.readlines(file).map do |line|
          enc = line.encoding.name
          # Get rid of invalid byte sequences
          line.encode!('UTF-16', enc, invalid: :replace, replace: '')
          line.encode!(enc, 'UTF-16')

          line.chomp
        end

        tokens, sexp, correlations = CLI.rip_source(source)

        cops.each do |cop_klass|
          cop = cop_klass.new
          cop.correlations = correlations
          cop.inspect(file, source, tokens, sexp)
          total_offences += cop.offences.count
          report << cop if cop.has_report?
        end

        report.display unless report.empty?
      end

      print "\n#{target_files(args).count} files inspected, "
      puts "#{total_offences} offences detected"

      return total_offences == 0 ? 0 : 1
    end

    def self.rip_source(source)
      tokens = Ripper.lex(source.join("\n")).map { |t| Cop::Token.new(*t) }
      sexp = Ripper.sexp(source.join("\n"))
      Cop::Position.make_position_objects(sexp)
      correlations = Cop::Grammar.new(tokens).correlate(sexp)
      [tokens, sexp, correlations]
    end

    def show_cops_on_duty(cops)
      puts "Reporting for duty:"
      cops.each { |c| puts c }
      puts "*******************"
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
