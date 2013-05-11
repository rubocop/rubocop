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
        "[[#{@pos.lineno}, #{@pos.column}], #{@type}, #{@text.inspect}]"
      end
    end

    class Cop
      attr_accessor :offences
      attr_accessor :debug
      attr_writer :correlations, :disabled_lines

      @all = []
      @config = {}

      class << self
        attr_accessor :all
        attr_accessor :config
      end

      def self.inherited(subclass)
        all << subclass
      end

      def self.cop_name
        name.to_s.split('::').last
      end

      def initialize
        @offences = []
        @debug = false
      end

      def has_report?
        !@offences.empty?
      end

      def add_offence(severity, line_number, message)
        unless @disabled_lines && @disabled_lines.include?(line_number)
          message = debug ? "#{name}: #{message}" : message
          @offences << Offence.new(severity, line_number, message)
        end
      end

      def name
        self.class.cop_name
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

      def find_all(sym, sexp)
        result = []
        each(sym, sexp) { |s| result << s }
        result
      end

      def find_first(sym, sexp)
        find_all(sym, sexp).first
      end

      def whitespace?(token)
        [:on_sp, :on_ignored_nl, :on_nl].include?(token.type)
      end

      def all_positions(sexp)
        return [sexp[2]] if sexp[0] =~ /^@/
        sexp.grep(Array).reduce([]) { |a, e| a + all_positions(e) }
      end

      def keywords(tokens)
        # We need to keep track of the previous token to avoid
        # interpreting :some_keyword as the keyword some_keyword.
        prev = Token.new(0, :init, '')
        # Same goes for defs so we need to track those as well.
        keywords = []

        tokens.reject { |t| whitespace?(t) }.each do |t|
          if prev.type != :on_symbeg && t.type == :on_kw &&
              [prev.type, prev.text] != [:on_kw, 'def']
            keywords << t
          end
          prev = t
        end

        keywords
      end

      def each_keyword(keyword, tokens)
        keywords(tokens).select { |t| t.text == keyword }.each { |t| yield t }
      end
    end
  end
end
