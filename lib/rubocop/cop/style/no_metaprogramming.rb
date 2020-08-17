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
        def_node_matcher :using_method_missing?, <<~PATTERN
          (def :method_missing ...)
        PATTERN

        METHOD_MISSING_MSG = 'Please do not use method_missing. Instead, explicitly define the'\
          ' methods you expect to receive.'

        ON_DEFS_ERROR_MAP = {
          included: 'self.included modifies the behavior of classes at runtime. Please avoid'\
            ' using if possible.',
          inherited: 'self.inherited modifies the behavior of classes at runtime. Please avoid'\
            ' using if possible.',
          method_added: 'Please do not use method_added, as it can change the behavior of the'\
            ' class at runtime.',
          method_removed: 'Please do not use method_removed, as it can change the behavior of'\
            ' the class at runtime.',
          method_undefined: 'Please do not use method_undefined, as it can change the behavior'\
            ' of the class at runtime.',
          singleton_method_added: 'Please do not use singleton_method_added, as it can change'\
            ' the behavior of the class at runtime.',
          singleton_method_removed: 'Please do not use singleton_method_removed, as it can'\
            ' change the behavior of the class at runtime.',
          singleton_method_undefined: 'Please do not use singleton_method_undefined, as it'\
            ' can change the behavior of the class at runtime.'
        }.freeze

        ON_SEND_ERROR_MAP = {
          class_eval: 'Please do not use class_eval to augment behavior onto a class. Instead,'\
            ' define the method you want to use in the class definition.',
          define_method: 'Please do not define methods dynamically, instead define them using'\
            ' `def` and explicitly. This helps readability for both humans and machines.',
          define_singleton_method: 'Please do not use define_singleton_method. Instead, define the'\
            ' method explicitly using `def self.my_method; end`',
          instance_eval: 'Please do not use instance_eval to augment behavior onto an instance.'\
            ' Instead, define the method you want to use in the class definition.'
        }.freeze

        def on_defs(node)
          return unless ON_DEFS_ERROR_MAP.key?(node.method_name)

          add_offense(node, message: ON_DEFS_ERROR_MAP[node.method_name])
        end

        def on_def(node)
          using_method_missing?(node) do
            add_offense(node, message: METHOD_MISSING_MSG)
          end
        end

        def on_send(node)
          return unless ON_SEND_ERROR_MAP.key?(node.method_name)

          add_offense(node, message: ON_SEND_ERROR_MAP[node.method_name])
        end
      end
    end
  end
end
