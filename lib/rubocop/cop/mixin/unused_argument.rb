# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Common functionality for cops handling unused arguments.
      module UnusedArgument
        extend NodePattern::Macros

        def_node_search :uses_var?, '(lvar %)'

        def join_force?(force_class)
          force_class == VariableForce
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each_value do |variable|
            check_argument(variable)
          end
        end

        def check_argument(variable)
          return if variable.should_be_unused?
          return if variable_used?(variable)

          message = message(variable)
          add_offense(variable.declaration_node, location: :name,
                                                 message: message)
        end

        def autocorrect(node)
          return if %i[kwarg kwoptarg].include?(node.type)

          if node.blockarg_type?
            lambda do |corrector|
              range = range_with_surrounding_space(node.source_range, :left)
              range = range_with_surrounding_comma(range, :left)
              corrector.remove(range)
            end
          else
            ->(corrector) { corrector.insert_before(node.loc.name, '_') }
          end
        end

        private

        def variable_used?(variable)
          return false unless variable.referenced?

          assignment_without_usage =
            find_assignment_without_variable_usage(variable)

          # If variable is either not assigned or assigned with usages,
          # then it's really used
          return true unless assignment_without_usage

          assignment_without_usage_pos =
            assignment_without_usage.node.source_range.begin_pos

          reference_positions =
            variable.references.map { |var| var.node.source_range.begin_pos }

          # Was variable referenced before it was reassigned?
          reference_positions.any? { |pos| pos <= assignment_without_usage_pos }
        end

        # Find the first variable assignment, which doesn't reference the
        # variable at the rhs.
        def find_assignment_without_variable_usage(variable)
          variable.assignments.find do |assignment|
            # It's impossible to decide whether a branch is executed, so
            # this case is ignored
            next if assignment.branch

            assignment_node = assignment.meta_assignment_node || assignment.node

            !uses_var?(assignment_node, assignment.variable.name)
          end
        end
      end
    end
  end
end
