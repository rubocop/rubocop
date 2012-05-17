require 'optparse'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    # Entry point for the application logic. Here we
    # do the command line arguments processing and inspect
    # the target files
    # @return [Fixnum] UNIX exit code
    def run
      options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: rubocop [options] [file1, file2, ...]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
      end.parse!

      cops = Cop::Cop.all
      total_offences = 0

      target_files.each do |file|
        report = Report.create(file)
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

      puts "\n#{target_files.count} files inspected, #{total_offences} offences detected"

      return 0
    end

    # Generate a list of target files by expanding globing patterns
    # (if any). If ARGV is empty recursively finds all Ruby source
    # files in the current directory
    # @return [Array] array of filenames
    def target_files
      return Dir['**/*.rb'] if ARGV.empty?

      if glob = ARGV.detect { |arg| arg =~ /\*/ }
        return Dir[glob]
      end
    end
  end
end
