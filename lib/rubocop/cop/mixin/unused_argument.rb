# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Common functionality for cops handling unused arguments.
      module UnusedArgument
        extend NodePattern::Macros

        def join_force?(force_class)
          force_class == VariableForce
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each_value do |variable|
            check_argument(variable)
          end
        end

        private

        def check_argument(variable)
          return if variable.should_be_unused?
          return if variable.referenced?

          message = message(variable)
          add_offense(variable.declaration_node, location: :name,
                                                 message: message)
        end
      end
    end
  end
end
