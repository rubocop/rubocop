# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for assignments in the conditions of
      # if/while/until.
      class AssignmentInCondition < Cop
        ASGN_NODES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn]
        MSG = 'Assignment in condition - you probably meant to use ==.'

        def on_if(node)
          check(node)
        end

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        private

        def check(node)
          condition, = *node

          # assignments inside blocks are not what we're looking for
          return if condition.type == :block

          on_node([:begin, *ASGN_NODES], condition) do |asgn_node|
            # skip safe assignment nodes if safe assignment is allowed
            return if safe_assignment_allowed? && safe_assignment?(asgn_node)

            # assignment nodes from shorthand ops like ||= don't have operator
            if asgn_node.type != :begin && asgn_node.loc.operator
              warning(asgn_node, :operator)
            end
          end
        end

        def safe_assignment?(node)
          node.type == :begin && node.children.size == 1 &&
            ASGN_NODES.include?(node.children[0].type)
        end

        def safe_assignment_allowed?
          cop_config['AllowSafeAssignment']
        end
      end
    end
  end
end
