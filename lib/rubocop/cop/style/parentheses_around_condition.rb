# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class ParenthesesAroundCondition < Cop
        MSG = "Don't use parentheses around the condition of an " +
          'if/unless/while/until'

        def on_if(node)
          process_control_op(node)

          super
        end

        def on_while(node)
          process_control_op(node)

          super
        end

        def on_until(node)
          process_control_op(node)

          super
        end

        private

        def process_control_op(node)
          cond, _body = *node

          cond_source = cond.loc.expression.source

          if cond_source.start_with?('(') && cond_source.end_with?(')')
            add_offence(:convention, cond.loc.expression, MSG)
          end
        end
      end
    end
  end
end
