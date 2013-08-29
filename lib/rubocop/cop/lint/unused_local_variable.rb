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
        TYPES_TO_ACCEPT_UNUSED =
          (ARGUMENT_DECLARATION_TYPES - [:shadowarg]).freeze

        def investigate(processed_source)
          inspect_variables(processed_source.ast)
        end

        def after_leaving_scope(scope)
          scope.variable_entries.each_value do |entry|
            next if entry.used?
            next if TYPES_TO_ACCEPT_UNUSED.include?(entry.node.type)
            next if entry.name.to_s.start_with?('_')
            message = sprintf(MSG, entry.name)
            warning(entry.node, :expression, message)
          end
        end
      end
    end
  end
end
