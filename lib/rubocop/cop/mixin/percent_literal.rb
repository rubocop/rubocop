# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for handling percent literals.
    module PercentLiteral
      def percent_literal?(node)
        if (begin_source = begin_source(node))
          begin_source.start_with?('%')
        end
      end

      def process(node, *types)
        on_percent_literal(node, types) if percent_literal?(node)
      end

      def begin_source(node)
        node.loc.begin.source if node.loc.respond_to?(:begin) && node.loc.begin
      end

      def type(node)
        node.loc.begin.source[0..-2]
      end
    end
  end
end
