# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      class NoMetaprogramming < Base
        def_node_matcher :included_definition?, <<~PATTERN
          (defs self :included ...)
        PATTERN

        def_node_matcher :inherited_definition?, <<~PATTERN
          (defs self :inherited ...)
        PATTERN

        def_node_matcher :using_method_missing?, <<~PATTERN
          (def :method_missing ...)
        PATTERN

        def_node_matcher :using_define_method?, <<~PATTERN
          (send _ :define_method ...)
        PATTERN

        def_node_matcher :using_instance_eval?, <<~PATTERN
          (send _ :instance_eval ...)
        PATTERN

        def_node_matcher :using_class_eval?, <<~PATTERN
          (send _ :class_eval ...)
        PATTERN

        def_node_matcher :using_define_singleton_method_on_klass_instance?, <<~PATTERN
          (send _ :define_singleton_method ...)
        PATTERN

        def on_defs(node)
          included_definition?(node) do
            add_offense(node, message: 'self.included modifies the behavior of classes at runtime. Please avoid using if possible.')
          end

          inherited_definition?(node) do
            add_offense(node, message: 'self.inherited modifies the behavior of classes at runtime. Please avoid using if possible.')
          end
        end

        def on_def(node)
          using_method_missing?(node) do
            add_offense(node, message: 'Please do not use method_missing. Instead, explicitly define the methods you expect to receive.')
          end
        end

        def on_send(node)
          using_define_method?(node) do
            add_offense(node, message: 'Please do not define methods dynamically, instead define them using `def` and explicitly. This helps readability for both humans and machines.')
          end

          using_define_singleton_method_on_klass_instance?(node) do
            add_offense(node, message: 'Please do not use define_singleton_method. Instead, define the method explicitly using `def self.my_method; end`')
          end

          using_instance_eval?(node) do
            add_offense(node, message: 'Please do not use instance_eval to augment behavior onto an instance. Instead, define the method you want to use in the class definition.')
          end

          using_class_eval?(node) do
            add_offense(node, message: 'Please do not use class_eval to augment behavior onto a class. Instead, define the method you want to use in the class definition.')
          end
        end
      end
    end
  end
end
