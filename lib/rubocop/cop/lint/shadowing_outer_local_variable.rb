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

        def before_declaring_variable(entry)
          # Only block scope can reference outer local variables.
          return unless variable_table.current_scope.node.type == :block
          return unless ARGUMENT_DECLARATION_TYPES.include?(entry.node.type)
          return if entry.name.to_s.start_with?('_')

          outer_local_variable = variable_table.find_variable_entry(entry.name)
          return unless outer_local_variable

          message = sprintf(MSG, entry.name)
          add_offence(:warning, entry.node.loc.expression, message)
        end
      end
    end
  end
end
