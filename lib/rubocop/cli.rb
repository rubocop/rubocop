require 'optparse'

module Rubocop
  # The CLI is a class responsible of handling all the command line interface
  # logic.
  class CLI
    def run
      options = {}

      OptionParser.new do |opts|
        opts.banner = "Usage: rubocop [options] [file1, file2, ...]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
      end.parse!

      cops = []
      cops << Cop::LineLengthCop

      target_files.each do |file|
        cops.each do |cop_klass|
          cop = cop_klass.new
          cop.inspect(file)
          cop.report
        end
      end

      return 0
    end

    def target_files
      return Dir['**/*.rb'] if ARGV.empty?

      if glob = ARGV.detect { |arg| arg =~ /\*/ }
        return Dir[glob]
      end
    end
  end
end
