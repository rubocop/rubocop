# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # Common functionality for cops handling unused arguments.
      module UnusedArgument
        def join_force?(force_class)
          force_class == VariableForce
        end

        def autocorrect(node)
          new_name = node.loc.expression.source.sub(/(\W?)(\w+)/, '\\1_\\2')
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.expression, new_name)
          end
        end

        def after_leaving_scope(scope, _variable_table)
          scope.variables.each_value do |variable|
            check_argument(variable)
          end
        end

        def check_argument(variable)
          return if variable.name.to_s.start_with?('_')
          return if variable.referenced?

          message = message(variable)
          add_offense(variable.declaration_node, :name, message)
        end
      end
    end
  end
end
