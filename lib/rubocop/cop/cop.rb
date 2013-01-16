# encoding: utf-8

module Rubocop
  module Cop
    class Position < Struct.new :lineno, :column
      # Does a recursive search and replaces each [lineno, column] array
      # in the sexp with a Position object.
      def self.make_position_objects(sexp)
        if sexp[0] =~ /^@/
          sexp[2] = Position.new(*sexp[2])
        else
          sexp.grep(Array).each { |s| make_position_objects(s) }
        end
      end

      # The point of this class is to provide named attribute access.
      # So we don't want backwards compatibility with array indexing.
      undef_method :[]
    end

    class Token
      attr_reader :pos, :type, :text

      def initialize(pos, type, text)
        @pos, @type, @text = Position.new(*pos), type, text
      end

      def to_s
        "[[#{@pos.lineno}, #{@pos.column}], #@type, #{@text.inspect}]"
      end
    end

    class Cop
      attr_accessor :offences
      attr_writer :correlations

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

      def initialize
        @offences = []
      end

      def has_report?
        !@offences.empty?
      end

      def add_offence(file, line_number, message)
        if self.class.enabled != false
          @offences << Offence.new(file, line_number, message)
        end
      end

      private

      def each_parent_of(sym, sexp)
        parents = []
        sexp.each do |elem|
          if Array === elem
            if elem[0] == sym
              parents << sexp unless parents.include?(sexp)
              elem = elem[1..-1]
            end
            each_parent_of(sym, elem) do |parent|
              parents << parent unless parents.include?(parent)
            end
          end
        end
        parents.each { |parent| yield parent }
      end

      def each(sym, sexp)
        yield sexp if sexp[0] == sym
        sexp.each do |elem|
          each(sym, elem) { |s| yield s } if Array === elem
        end
      end

      def whitespace?(token)
        [:on_sp, :on_ignored_nl, :on_nl].include?(token.type)
      end
    end
  end
end
