# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop looks for unused local variables in each scope.
      # Actually this is a mimic of the warning
      # "assigned but unused variable - foo" from `ruby -cw`.
      class UnusedLocalVariable < Cop
        include VariableInspector

        MSG = 'Assigned but unused variable - %s'

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
