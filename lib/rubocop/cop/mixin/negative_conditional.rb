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

      def check_negative_conditional(node, message:, &block) # rubocop:disable Metrics/CyclomaticComplexity
        condition = node.condition

        return if empty_condition?(condition)

        condition = condition.children.last while condition.begin_type?

        unless single_negative?(condition) ||
               (check_chained_conditions? && chained_negatives?(condition))
          return
        end
        return if node.if_type? && node.else?

        add_offense(node, message: message, &block)
      end

      def chained_negatives?(node)
        return false unless node.operator_keyword?

        expected_operator = node.operator
        loop do
          return false unless single_negative?(node.rhs)

          node = node.lhs

          return single_negative?(node) unless node.operator_keyword?
          return false unless node.operator == expected_operator
        end
      end

      def check_chained_conditions?
        !cop_config['AllowChainedConditions']
      end
    end
  end
end
