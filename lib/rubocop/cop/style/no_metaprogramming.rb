# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Discourages the use of metaprogramming. It's designed
      # to be enabled in select folders within your application. It was
      # originally developed with the idea of "Business logic should minimize
      # the amount of metaprogramming."
      #
      # This cop specifically will warn on usage of `.included`, `.inherited`,
      # `#method_missing`, `.define_method`, `#instance_eval`, `.class_eval`,
      # and `.define_singleton_method`.
      #
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

        INCLUDED_MSG = 'self.included modifies the behavior of classes at runtime. Please avoid'\
          ' using if possible.'

        INHERITED_MSG = 'self.inherited modifies the behavior of classes at runtime. Please avoid'\
          ' using if possible.'

        METHOD_MISSING_MSG = 'Please do not use method_missing. Instead, explicitly define the'\
          ' methods you expect to receive.'

        DEFINE_METHOD_MSG = 'Please do not define methods dynamically, instead define them using'\
          ' `def` and explicitly. This helps readability for both humans and machines.'

        DEFINE_SINGLETON_MSG = 'Please do not use define_singleton_method. Instead, define the'\
          ' method explicitly using `def self.my_method; end`'

        INSTANCE_EVAL_MSG = 'Please do not use instance_eval to augment behavior onto an instance.'\
          ' Instead, define the method you want to use in the class definition.'

        CLASS_EVAL_MSG = 'Please do not use class_eval to augment behavior onto a class. Instead,'\
          ' define the method you want to use in the class definition.'

        def on_defs(node)
          included_definition?(node) do
            add_offense(node, message: INCLUDED_MSG)
          end

          inherited_definition?(node) do
            add_offense(node, message: INHERITED_MSG)
          end
        end

        def on_def(node)
          using_method_missing?(node) do
            add_offense(node, message: METHOD_MISSING_MSG)
          end
        end

        def on_send(node)
          using_define_method?(node) do
            add_offense(node, message: DEFINE_METHOD_MSG)
          end

          using_define_singleton_method_on_klass_instance?(node) do
            add_offense(node, message: DEFINE_SINGLETON_MSG)
          end

          using_instance_eval?(node) do
            add_offense(node, message: INSTANCE_EVAL_MSG)
          end

          using_class_eval?(node) do
            add_offense(node, message: CLASS_EVAL_MSG)
          end
        end
      end
    end
  end
end
