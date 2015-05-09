# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for nested method definitions.
      #
      # @example
      #   # `bar` definition actually produces methods in the same scope
      #   # as the outer `foo` method. Furthermore, the `bar` method
      #   # will be redefined every time the `foo` is invoked
      #   def foo
      #     def bar
      #     end
      #   end
      #
      class NestedMethodDefinition < Cop
        include OnMethodDef

        MSG = 'Method definitions must not be nested. ' \
              'Use `lambda` instead.'

        def on_method_def(node, _method_name, _args, _body)
          node.each_descendant(:def) do |nested_def_node|
            add_offense(nested_def_node, :expression)
          end
        end
      end
    end
  end
end
