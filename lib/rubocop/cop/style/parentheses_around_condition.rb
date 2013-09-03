# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for the presence of superfluous parentheses around the
      # condition of if/while/until.
      class ParenthesesAroundCondition < Cop
        ASGN_NODES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn]
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
            # allow safe assignment
            return if safe_assignment?(cond) && safe_assignment_allowed?

            convention(cond, :expression)
          end
        end

        def safe_assignment?(node)
          node.children.size == 1 && ASGN_NODES.include?(node.children[0].type)
        end

        def safe_assignment_allowed?
          cop_config['AllowSafeAssignment']
        end
      end
    end
  end
end
