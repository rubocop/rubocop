# encoding: utf-8

module RuboCop
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
        include UnusedArgument

        def check_argument(variable)
          return unless variable.method_argument?
          return if variable.keyword_argument? &&
                    cop_config['AllowUnusedKeywordArguments']

          _name, _args, body = *variable.scope.node
          return if cop_config['IgnoreEmptyMethods'] && body.nil?
          return if variable.name == :block && yield_called?(body)

          super
        end

        def message(variable)
          message = "Unused method argument - `#{variable.name}`."

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

        private

        def yield_called?(node)
          return false if node.nil?
          return true if node.respond_to?(:yield_type?) && node.yield_type?
          return true if node.each_node(:yield).any?
          false
        end
      end
    end
  end
end
