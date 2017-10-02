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
      end
    end
  end
end
