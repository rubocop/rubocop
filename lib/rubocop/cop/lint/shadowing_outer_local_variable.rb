# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop looks for use of the same name as outer local variables
      # for block arguments or block local variables.
      # This is a mimic of the warning
      # "shadowing outer local variable - foo" from `ruby -cw`.
      class ShadowingOuterLocalVariable < Cop
        include VariableInspector

        MSG = 'Shadowing outer local variable - %s'

        def investigate(processed_source)
          inspect_variables(processed_source.ast)
        end

        def before_declaring_variable(variable)
          return if variable.name.to_s.start_with?('_')

          outer_local_variable = variable_table.find_variable(variable.name)
          return unless outer_local_variable

          message = sprintf(MSG, variable.name)
          add_offence(variable.declaration_node, :expression, message)
        end
      end
    end
  end
end
