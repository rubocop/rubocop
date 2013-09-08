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
            message = sprintf(MSG, variable.name)
            warning(assignment.node, :expression, message)
          end
        end

        def check_for_unused_block_local_variable(variable)
          return unless variable.block_local_variable?
          return unless variable.assignments.empty?
          message = sprintf(MSG, variable.name)
          warning(variable.declaration_node, :expression, message)
        end
      end
    end
  end
end
