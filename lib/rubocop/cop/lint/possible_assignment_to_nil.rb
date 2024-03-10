# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks if the left hand side of an assignment can evaluate to nil. This means that it
      # detects if the safe navigation operator `&.` is used on the left hand side of any kind of
      # assignment.
      #
      # @example
      #
      #   # bad (using safe navigation without reason)
      #   a&.value ||= 10
      #
      #   # good
      #   a.value ||= 10
      #
      # @example
      #
      #   # bad (using safe navigation correctly, but assignment instead of equality)
      #   do_something if a&.value = 0
      #
      #   # good
      #   do_something if a&.value == 0
      #
      class PossibleAssignmentToNil < Base
        include RangeHelp

        MSG = 'The target of the assignment can evaluate to `nil` due to the `&.` operator.'

        def on_assignment(node)
          lhs, _rhs = *node
          register_offense(node) if lhs.csend_type?
        end

        alias on_or_asgn  on_assignment
        alias on_and_asgn on_assignment
        alias on_op_asgn  on_assignment

        def on_csend(node)
          register_offense(node) if node.assignment_method?
        end

        private

        def register_offense(csend_node)
          add_offense(range_between(csend_node.source_range.begin_pos,
                                    csend_node.loc.selector.end_pos))
        end
      end
    end
  end
end
