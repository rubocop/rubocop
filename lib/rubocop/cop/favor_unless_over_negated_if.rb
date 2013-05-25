# encoding: utf-8

module Rubocop
  module Cop
    module FavorOtherKeywordOverNegation
      def check(node)
        condition, _body, _rest = *node

        # Look at last expression of contents if there's a parenthesis
        # around condition.
        *_, condition = *condition while condition.type == :begin

        if condition.type == :send
          _object, method = *condition
          if method == :! && !(node.loc.respond_to?(:else) && node.loc.else)
            add_offence(:convention, node.loc.expression.line,
                        error_message)
          end
        end
      end
    end

    class FavorUnlessOverNegatedIf < Cop
      include FavorOtherKeywordOverNegation

      def on_if(node)
        check(node)
        super
      end

      def error_message
        'Favor unless (or control flow or) over if for negative conditions.'
      end
    end

    class FavorUntilOverNegatedWhile < Cop
      include FavorOtherKeywordOverNegation

      def on_while(node)
        check(node)
        super
      end

      def error_message
        'Favor until over while for negative conditions.'
      end
    end
  end
end
