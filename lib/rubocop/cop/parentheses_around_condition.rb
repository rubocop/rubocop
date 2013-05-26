# encoding: utf-8

module Rubocop
  module Cop
    class ParenthesesAroundCondition < Cop
      MSG = "Don't use parentheses around the condition of an " +
        'if/unless/while/until, unless the condition contains an assignment.'

      def inspect(source, tokens, ast, comments)
        on_node([:if, :while, :until], ast) do |node|
          cond, _body = *node

          cond_source = cond.loc.expression.source

          if cond_source.start_with?('(') && cond_source.end_with?(')')
            add_offence(:convetion,
                        cond.loc.line,
                        MSG)
          end
        end
      end
    end
  end
end
