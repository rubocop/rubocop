# encoding: utf-8

module Rubocop
  module Cop
    Position = Struct.new :row, :column

    class Token
      attr_reader :pos, :name, :text

      def initialize(pos, name, text)
        @pos, @name, @text = Position.new(*pos), name, text
      end
    end

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
        case method(:inspect).arity
        when 2
          inspect(file, source)
        else
          tokens = Ripper.lex(source.join("\n")).map { |t| Token.new(*t) }
          sexp = Ripper.sexp(source.join("\n"))
          Cop.make_position_objects(sexp)
          inspect(file, source, tokens, sexp)
        end
      end

      def add_offence(file, line_number, line, message)
        @offences << Offence.new(file, line_number, line, message)
      end

      # Does a recursive search and replaces each [row, column] array
      # in the sexp with a Position object.
      def self.make_position_objects(sexp)
        if sexp[0] =~ /^@/
          sexp[2] = Position.new(*sexp[2])
        else
          sexp.grep(Array).each { |s| make_position_objects(s) }
        end
      end

      private

      def each_parent_of(sym, sexp)
        parents = []
        sexp.each do |elem|
          if Array === elem
            if elem[0] == sym
              parents << sexp
              elem = elem[1..-1]
            end
            each_parent_of(sym, elem) { |parent| parents << parent }
          end
        end
        parents.uniq.each { |parent| yield parent }
      end

      def each(sym, sexp)
        yield sexp if sexp[0] == sym
        sexp.each do |elem|
          each(sym, elem) { |s| yield s } if Array === elem
        end
      end

      def whitespace?(token)
        [:on_sp, :on_ignored_nl, :on_nl].include?(token.name)
      end
    end
  end
end
