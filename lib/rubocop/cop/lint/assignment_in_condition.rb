# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for assignments in the conditions of
      # if/while/until.
      class AssignmentInCondition < Cop
        include SafeAssignment

        MSG = 'Assignment in condition - you probably meant to use `==`.'.freeze
        ASGN_TYPES = [:begin, *EQUALS_ASGN_NODES, :send].freeze

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
          traverse_node(condition, ASGN_TYPES) do |asgn_node|
            if asgn_node.type == :send
              _receiver, method_name, *_args = *asgn_node
              next :skip_children if method_name !~ /=\z/
            end

            # skip safe assignment nodes if safe assignment is allowed
            if safe_assignment_allowed? && safe_assignment?(asgn_node)
              next :skip_children
            end

            # assignment nodes from shorthand ops like ||= don't have operator
            if asgn_node.type != :begin && asgn_node.loc.operator
              add_offense(asgn_node, :operator)
            end
          end
        end

        # each_node/visit_descendants_with_types with :skip_children
        def traverse_node(node, types, &block)
          result = yield node if types.include?(node.type)
          # return to skip all descendant nodes
          return if result == :skip_children
          node.children.each do |child|
            traverse_node(child, types, &block) if child.is_a?(Node)
          end
        end
      end
    end
  end
end
