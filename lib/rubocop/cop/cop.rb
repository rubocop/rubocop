module Rubocop
  module Cop
    class Cop
      attr_accessor :offences

      @all = []
      @enabled = []
      @config = {}

      class << self
        attr_accessor :all
        attr_accessor :enabled
        attr_accessor :config
      end

      def self.inherited(subclass)
        puts "Registering cop #{subclass}"
        all << subclass
      end

      def self.enabled
        all.select(&:enabled?)
      end

      def self.enabled?
        true
      end

      def initialize
        @offences = []
      end

      def has_report?
        !@offences.empty?
      end

      def inspect_source(file, source)
        tokens = Ripper.lex(source.join("\n"))
        sexp = Ripper.sexp(source.join("\n"))
        inspect(file, source, tokens, sexp)
      end
      
      def add_offence(file, line_number, line, message)
        @offences << Offence.new(file, line_number, line, message)
      end

      private

      def each_parent_of(sym, sexp)
        parents = []
        sexp.each { |elem|
          if Array === elem
            if elem[0] == sym
              parents << sexp
            else
              each_parent_of(sym, elem) { |parent| parents << parent }
            end
          end
        }
        parents.uniq.each { |parent| yield parent }
      end
    end
  end
end
