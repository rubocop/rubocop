# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop checks for unused method arguments.
      #
      # @example
      #
      #   def some_method(used, unused, _unused_but_allowed)
      #     puts used
      #   end
      class UnusedMethodArgument < Cop
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
          return unless variable.method_argument?
          return if variable.name.to_s.start_with?('_')
          return if variable.referenced?

          message = message(variable)
          add_offense(variable.declaration_node, :name, message)
        end

        def message(variable)
          message = "Unused method argument - `#{variable.name}`. " \
                    "If it's necessary, use `_` or `_#{variable.name}` " \
                    "as an argument name to indicate that it won't be used."

          scope = variable.scope
          all_arguments = scope.variables.each_value.select(&:method_argument?)

          if all_arguments.none?(&:referenced?)
            message << " You can also write as `#{scope.name}(*)` " \
                       'if you want the method to accept any arguments ' \
                       "but don't care about them."
          end

          message
        end
      end
    end
  end
end
