# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for unused method arguments.
      #
      # @example
      #
      #   # bad
      #
      #   def some_method(used, unused, _unused_but_allowed)
      #     puts used
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method(used, _unused, _unused_but_allowed)
      #     puts used
      #   end
      class UnusedMethodArgument < Cop
        include UnusedArgument

        def autocorrect(node)
          UnusedArgCorrector.correct(processed_source, node)
        end

        private

        def check_argument(variable)
          return unless variable.method_argument?
          return if variable.keyword_argument? &&
                    cop_config['AllowUnusedKeywordArguments']

          if cop_config['IgnoreEmptyMethods']
            body = variable.scope.node.body

            return if body.nil?
          end

          super
        end

        def message(variable)
          message = +"Unused method argument - `#{variable.name}`."

          unless variable.keyword_argument?
            message << " If it's necessary, use `_` or `_#{variable.name}` " \
                       "as an argument name to indicate that it won't be used."
          end

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
