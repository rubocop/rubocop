# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for assignments in the conditions of
      # if/while/until.
      #
      # @example
      #
      #   # bad
      #
      #   if some_var = true
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   if some_var == true
      #     do_something
      #   end
      class AssignmentInCondition < Cop
        include SafeAssignment

        MSG_WITH_SAFE_ASSIGNMENT_ALLOWED =
          'Use `==` if you meant to do a comparison or wrap the expression ' \
          'in parentheses to indicate you meant to assign in a ' \
          'condition.'.freeze
        MSG_WITHOUT_SAFE_ASSIGNMENT_ALLOWED =
          'Use `==` if you meant to do a comparison or move the assignment ' \
          'up out of the condition.'.freeze
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

        def message(_node)
          if safe_assignment_allowed?
            MSG_WITH_SAFE_ASSIGNMENT_ALLOWED
          else
            MSG_WITHOUT_SAFE_ASSIGNMENT_ALLOWED
          end
        end

        def check(node)
          return if node.condition.block_type?

          traverse_node(node.condition, ASGN_TYPES) do |asgn_node|
            next :skip_children if skip_children?(asgn_node)
            next if allowed_construct?(asgn_node)

            add_offense(asgn_node, location: :operator)
          end
        end

        def allowed_construct?(asgn_node)
          asgn_node.begin_type? || conditional_assignment?(asgn_node)
        end

        def conditional_assignment?(asgn_node)
          !asgn_node.loc.operator
        end

        def skip_children?(asgn_node)
          (asgn_node.send_type? && asgn_node.method_name !~ /=\z/) ||
            empty_condition?(asgn_node) ||
            (safe_assignment_allowed? && safe_assignment?(asgn_node))
        end

        # each_node/visit_descendants_with_types with :skip_children
        def traverse_node(node, types, &block)
          result = yield node if types.include?(node.type)

          return if result == :skip_children

          node.each_child_node { |child| traverse_node(child, types, &block) }
        end
      end
    end
  end
end
