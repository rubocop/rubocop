# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Some common code shared between FavorUnlessOverNegatedIf and
    # FavorUntilOverNegatedWhile.
    module NegativeConditional
      def self.included(mod)
        mod.def_node_matcher :single_negative?, '(send !(send _ :!) :!)'
      end

      def check_negative_conditional(node)
        condition, _body, _rest = *node

        # Look at last expression of contents if there are parentheses
        # around condition.
        condition = condition.children.last while condition.type == :begin

        return unless single_negative?(condition) &&
                      !(node.loc.respond_to?(:else) && node.loc.else)

        add_offense(node, :expression)
      end
    end
  end
end
