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
      extend AST::Sexp

      attr_accessor :offences
      attr_accessor :debug
      attr_writer :disabled_lines

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

      def on_node(syms, sexp, excludes = [])
        yield sexp if Array(syms).include?(sexp.type)

        return if Array(excludes).include?(sexp.type)

        sexp.children.each do |elem|
          if Parser::AST::Node === elem
            on_node(syms, elem, excludes) { |s| yield s }
          end
        end
      end
    end
  end
end
