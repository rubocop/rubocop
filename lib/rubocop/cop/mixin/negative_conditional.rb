# encoding: utf-8

module Rubocop
  module Cop
    # Some common code shared between FavorUnlessOverNegatedIf and
    # FavorUntilOverNegatedWhile.
    module NegativeConditional
      def check(node)
        condition, _body, _rest = *node

        # Look at last expression of contents if there's a parenthesis
        # around condition.
        condition = condition.children.last while condition.type == :begin

        if condition.type == :send
          _object, method = *condition
          if method == :! && !(node.loc.respond_to?(:else) && node.loc.else)
            add_offence(node, :expression, error_message)
          end
        end
      end
    end
  end
end
