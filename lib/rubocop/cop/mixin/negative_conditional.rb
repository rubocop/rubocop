# encoding: utf-8

module RuboCop
  module Cop
    # Some common code shared between FavorUnlessOverNegatedIf and
    # FavorUntilOverNegatedWhile.
    module NegativeConditional
      def check_negative_conditional(node)
        condition, _body, _rest = *node

        # Look at last expression of contents if there's a parenthesis
        # around condition.
        condition = condition.children.last while condition.type == :begin
        return unless condition.type == :send

        _object, method = *condition
        return unless method == :! && !(node.loc.respond_to?(:else) &&
                                        node.loc.else)

        add_offense(node, :expression)
      end
    end
  end
end
