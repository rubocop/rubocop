# frozen_string_literal: true

module RuboCop
  module Ext
    # Extensions to AST::RegexpNode for our cached parsed regexp info
    module RegexpNode
      ANY = Object.new
      def ANY.==(_)
        true
      end
      private_constant :ANY

      class << self
        attr_reader :parsed_cache
      end
      @parsed_cache = {}

      # @return [Regexp::Expression::Root, nil]
      def parsed_tree
        return if interpolation?

        str = content
        Ext::RegexpNode.parsed_cache[str] ||= begin
          Regexp::Parser.parse(str)
        rescue StandardError
          nil
        end
      end

      def each_capture(named: ANY)
        return enum_for(__method__, named: named) unless block_given?

        parsed_tree&.traverse do |event, exp, _index|
          yield(exp) if event == :enter &&
                        named == exp.respond_to?(:name) &&
                        exp.respond_to?(:capturing?) &&
                        exp.capturing?
        end

        self
      end

      AST::RegexpNode.include self
    end
  end
end
