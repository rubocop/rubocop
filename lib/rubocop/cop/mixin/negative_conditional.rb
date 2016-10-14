# frozen_string_literal: true

module RuboCop
  module Cop
    # Some common code shared between FavorUnlessOverNegatedIf and
    # FavorUntilOverNegatedWhile.
    module NegativeConditional
      extend NodePattern::Macros
      include IfNode

      def_node_matcher :single_negative?, '(send !(send _ :!) :!)'
      def_node_matcher :empty_condition?, '(begin)'

      def check_negative_conditional(node)
        condition, _body, _rest = *node

        return if empty_condition?(condition)

        # Look at last expression of contents if there are parentheses
        # around condition.
        condition = condition.children.last while condition.begin_type?

        return unless single_negative?(condition) && !if_else?(node)

        add_offense(node, :expression)
      end
    end
  end
end
