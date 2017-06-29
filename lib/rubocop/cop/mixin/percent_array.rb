# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling percent arrays.
    module PercentArray
      private

      # Ruby does not allow percent arrays in an ambiguous block context.
      #
      # @example
      #
      #   foo %i[bar baz] { qux }
      def invalid_percent_array_context?(node)
        parent = node.parent

        parent && parent.send_type? && parent.arguments.include?(node) &&
          !parent.parenthesized? && parent.block_literal?
      end

      def allowed_bracket_array?(node)
        comments_in_array?(node) || below_array_length?(node) ||
          invalid_percent_array_context?(node)
      end

      def message(_node)
        style == :percent ? self.class::PERCENT_MSG : self.class::ARRAY_MSG
      end

      def comments_in_array?(node)
        comments = processed_source.comments
        array_range = node.source_range.to_a

        comments.any? do |comment|
          !(comment.loc.expression.to_a & array_range).empty?
        end
      end

      def check_percent_array(node)
        array_style_detected(:percent, node.values.size)
        add_offense(node) if style == :brackets
      end

      def check_bracketed_array(node)
        return if allowed_bracket_array?(node)

        array_style_detected(:brackets, node.values.size)
        add_offense(node) if style == :percent
      end
    end
  end
end
