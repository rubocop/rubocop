# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Common functionality for cops handling unused arguments.
      module UnusedArgument
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
          return if variable.referenced?

          message = message(variable)
          add_offense(variable.declaration_node, :name, message)
        end

        def autocorrect(node)
          return if [:kwarg, :kwoptarg].include?(node.type)

          ->(corrector) { corrector.insert_before(node.loc.name, '_') }
        end
      end
    end
  end
end
