# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the class/module name instead of
      # self, when defining class/module methods.
      #
      # @example
      #   # bad
      #   class SomeClass
      #     def SomeClass.class_method
      #       # ...
      #     end
      #   end
      #
      #   # good
      #   class SomeClass
      #     def self.class_method
      #       # ...
      #     end
      #   end
      class ClassMethods < Cop
        MSG = 'Use `self.%<method>s` instead of `%<class>s.%<method>s`.'

        def on_class(node)
          return unless node.body

          if node.body.defs_type?
            check_defs(node.identifier, node.body)
          elsif node.body.begin_type?
            node.body.each_child_node(:defs) do |def_node|
              check_defs(node.identifier, def_node)
            end
          end
        end
        alias on_module on_class

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.name, 'self') }
        end

        private

        def check_defs(name, node)
          # check if the class/module name matches the definee for the defs node
          return unless name == node.receiver

          add_offense(node.receiver, location: :name)
        end

        def message(node)
          _, class_name = *node

          format(MSG, method: node.parent.method_name, class: class_name)
        end
      end
    end
  end
end
