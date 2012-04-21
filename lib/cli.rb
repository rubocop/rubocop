module Rubocop
  # The cli is a class responsible of handling all the command line interface
  # logic.
  class Cli
    def initialize(args = ARGV)
      @args = args
    end

    def run
      Rubocop.run(target_files)
    end

    def target_files
      return Dir['**/*.rb'] if @args.empty?
      
      if glob = @args.detect { |arg| arg =~ /\*/ }
        return Dir[glob]
      end
    end
  end
end
