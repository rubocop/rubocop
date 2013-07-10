# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for the presence of superfluous parentheses around the
      # condition of if/while/until.
      class ParenthesesAroundCondition < Cop
        MSG = "Don't use parentheses around the condition of an " +
          'if/unless/while/until'

        def on_if(node)
          process_control_op(node)
        end

        def on_while(node)
          process_control_op(node)
        end

        def on_until(node)
          process_control_op(node)
        end

        private

        def process_control_op(node)
          cond, _body = *node

          if cond.type == :begin
            add_offence(:convention, cond.loc.expression, MSG)
          end
        end
      end
    end
  end
end
