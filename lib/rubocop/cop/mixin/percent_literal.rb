# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling percent literals.
    module PercentLiteral
      def percent_literal?(node)
        return unless (begin_source = begin_source(node))
        begin_source.start_with?('%')
      end

      def process(node, *types)
        return unless percent_literal?(node) && types.include?(type(node))
        on_percent_literal(node)
      end

      def begin_source(node)
        node.loc.begin.source if node.loc.respond_to?(:begin) && node.loc.begin
      end

      def type(node)
        node.loc.begin.source[0..-2]
      end

      # A range containing only the contents of the percent literal (e.g. in
      # %i{1 2 3} this will be the range covering '1 2 3' only)
      def contents_range(node)
        Parser::Source::Range.new(
          node.loc.expression.source_buffer,
          node.loc.begin.end_pos,
          node.loc.end.begin_pos
        )
      end
    end
  end
end
