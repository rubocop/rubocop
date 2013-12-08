# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for every useless assignment to local variable in every
      # scope.
      # The basic idea for this cop was from the warning of `ruby -cw`:
      #
      #   assigned but unused variable - foo
      #
      # Currently this cop has advanced logic that detects unreferenced
      # reassignments and properly handles varied cases such as branch, loop,
      # rescue, ensure, etc.
      class UselessAssignment < Cop
        include VariableInspector

        MSG = 'Useless assignment to variable - %s'

        def investigate(processed_source)
          inspect_variables(processed_source.ast)
        end

        def after_leaving_scope(scope)
          scope.variables.each_value do |variable|
            check_for_unused_assignments(variable)
            check_for_unused_block_local_variable(variable)
          end
        end

        def check_for_unused_assignments(variable)
          return if variable.name.to_s.start_with?('_')

          variable.assignments.each do |assignment|
            next if assignment.used?

            message = message_for_useless_assignment(assignment)

            location = if assignment.regexp_named_capture?
                         assignment.node.children.first.loc.expression
                       else
                         assignment.node.loc.name
                       end

            add_offence(nil, location, message)
          end
        end

        def message_for_useless_assignment(assignment)
          variable = assignment.variable

          message = sprintf(MSG, variable.name)

          if assignment.multiple_assignment?
            message << ". Use _ or _#{variable.name} as a variable name " +
                       "to indicate that it won't be used."
          elsif assignment.operator_assignment?
            return_value_node = return_value_node_of_scope(variable.scope)
            if assignment.meta_assignment_node.equal?(return_value_node)
              non_assignment_operator = assignment.operator.sub(/=$/, '')
              message << ". Use just operator #{non_assignment_operator}."
            end
          end

          message
        end

        # TODO: More precise handling (rescue, ensure, nested begin, etc.)
        def return_value_node_of_scope(scope)
          body_node = scope.body_node

          if body_node.type == :begin
            body_node.children.last
          else
            body_node
          end
        end

        def check_for_unused_block_local_variable(variable)
          return unless variable.block_local_variable?
          return unless variable.assignments.empty?
          message = sprintf(MSG, variable.name)
          add_offence(variable.declaration_node, :expression, message)
        end
      end
    end
  end
end
