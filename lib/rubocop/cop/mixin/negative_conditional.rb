# frozen_string_literal: true

module RuboCop
  module Cop
    # Some common code shared between `NegatedIf` and
    # `NegatedWhile` cops.
    module NegativeConditional
      extend NodePattern::Macros

      MSG = 'Favor `%<inverse>s` over `%<current>s` for negative conditions.'

      private

      # @!method single_negative?(node)
      def_node_matcher :single_negative?, '(send !(send _ :!) :!)'

      # @!method empty_condition?(node)
      def_node_matcher :empty_condition?, '(begin)'

      def check_negative_conditional(node, message:, &correction)
        condition = node.condition

        return if empty_condition?(condition)

        condition = condition.children.last while condition.begin_type?

        return unless single_negative?(condition)
        return if node.if_type? && node.else?

        correction = nil if negation_loses_comment?(condition)
        add_offense(node, message: message, &correction)
      end

      def negation_loses_comment?(condition)
        return false if condition.single_line?

        range = condition.source_range
        operand = condition.receiver.source_range
        processed_source.each_comment_in_lines(range.line..range.last_line).any? do |comment|
          range.contains?(comment.source_range) && !operand.contains?(comment.source_range)
        end
      end
    end
  end
end
