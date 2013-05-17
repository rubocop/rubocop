# encoding: utf-8

module Rubocop
  module Cop
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
