# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      class AssignmentInCondition < Cop
        ASGN_NODES = [:lvasgn, :ivasgn, :cvasgn, :gvasgn, :casgn]
        MSG = 'Assignment in condition - you probably meant to use ==.'

        def on_if(node)
          check(node)
          super
        end

        def on_while(node)
          check(node)
          super
        end

        def on_until(node)
          check(node)
          super
        end

        private

        def check(node)
          condition, = *node

          on_node(ASGN_NODES , condition) do |asgn_node|
            # assignment nodes from shorthand ops like ||= don't have operator
            if asgn_node.loc.operator
              add_offence(:warning, asgn_node.loc.operator, MSG)
            end
          end
        end
      end
    end
  end
end
