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
        MSG = 'Use `self.%<method>s` instead of `%<class>s.%<method>s`.'.freeze

        def on_class(node)
          name, _superclass, body = *node
          check(name, body)
        end

        def on_module(node)
          name, body = *node
          check(name, body)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.name, 'self') }
        end

        private

        def check(name, node)
          return unless node

          if node.defs_type?
            check_defs(name, node)
          elsif node.begin_type?
            node.each_child_node(:defs) { |n| check_defs(name, n) }
          end
        end

        def check_defs(name, node)
          definee, method_name, _args, _body = *node
          # check if the class/module name matches the definee for the defs node
          return unless name == definee

          _, class_name = *definee
          add_offense(definee, location: :name,
                               message: message(class_name, method_name))
        end

        def message(class_name, method_name)
          format(MSG, method: method_name, class: class_name)
        end
      end
    end
  end
end
