# encoding: utf-8

module Rubocop
  module Cop
    module FavorOtherKeywordOverNegation
      def inspect(file, source, tokens, ast)
        keyword, msg = specifics
        on_node(keyword, ast) do |if_node|
          condition, _body, rest = *if_node

          # Look at last expression of contents if there's a
          # parenthesis around condition.
          *_, condition = *condition while condition.type == :begin

          if condition.type == :send
            object, method = *condition
            if method == :! && !(if_node.src.respond_to?(:else) &&
                                 if_node.src.else)
              add_offence(:convention, if_node.src.expression.line, msg)
            end
          end
        end
      end
    end

    class FavorUnlessOverNegatedIf < Cop
      include FavorOtherKeywordOverNegation

      def specifics
        [:if,
         'Favor unless (or control flow or) over if for negative conditions.']
      end
    end

    class FavorUntilOverNegatedWhile < Cop
      include FavorOtherKeywordOverNegation

      def specifics
        [:while, 'Favor until over while for negative conditions.']
      end
    end
  end
end
