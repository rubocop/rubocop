# frozen_string_literal: true

module RuboCop
  module Cop
    # Some common code shared between `NegatedIf` and
    # `NegatedWhile` cops.
    module NegativeConditional
      extend NodePattern::Macros

      def_node_matcher :single_negative?, '(send !(send _ :!) :!)'
      def_node_matcher :empty_condition?, '(begin)'

      def check_negative_conditional(node)
        condition = node.condition

        return if empty_condition?(condition)

        condition = condition.children.last while condition.begin_type?

        return unless single_negative?(condition)
        return if node.if_type? && node.else?

        add_offense(node, :expression)
      end

      def negative_conditional_corrector(node)
        condition = negated_condition(node)

        lambda do |corrector|
          corrector.replace(node.loc.keyword, node.inverse_keyword)
          corrector.replace(condition.source_range,
                            condition.children.first.source)
        end
      end

      def negated_condition(node)
        condition = node.condition
        condition = condition.children.first while condition.begin_type?
        condition
      end
    end
  end
end
