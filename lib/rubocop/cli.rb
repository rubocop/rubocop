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
      options = { :mode => :default }

      OptionParser.new do |opts|
        opts.banner = "Usage: rubocop [options] [file1, file2, ...]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
        opts.on("-e", "--emacs", "Emacs style output") do
          options[:mode] = :emacs_style
        end
      end.parse!(args)

      cops = Cop::Cop.all
      total_offences = 0

      target_files(args).each do |file|
        report = Report.create(file, options[:mode])
        source = File.readlines(file)
        tokens = Ripper.lex(source.join)
        sexp = Ripper.sexp(source.join)

        cops.each do |cop_klass|
          cop = cop_klass.new
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

    # Generate a list of target files by expanding globing patterns
    # (if any). If args is empty recursively finds all Ruby source
    # files in the current directory
    # @return [Array] array of filenames
    def target_files(args)
      return Dir['**/*.rb'] if args.empty?

      if glob = args.detect { |arg| arg =~ /\*/ }
        Dir[glob]
      else
        args
      end
    end
  end
end
