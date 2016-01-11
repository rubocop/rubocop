# encoding: utf-8
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
      #       ...
      #     end
      #   end
      #
      #   # good
      #   class SomeClass
      #     def self.class_method
      #       ...
      #     end
      #   end
      class ClassMethods < Cop
        MSG = 'Use `self.%s` instead of `%s.%s`.'.freeze

        def on_class(node)
          name, _superclass, body = *node
          check(name, body)
        end

        def on_module(node)
          name, body = *node
          check(name, body)
        end

        private

        def check(name, node)
          return unless node

          if node.type == :defs
            check_defs(name, node)
          elsif node.type == :begin
            defs_nodes = node.children.compact.select { |n| n.type == :defs }
            defs_nodes.each { |n| check_defs(name, n) }
          end
        end

        def check_defs(name, node)
          definee, method_name, _args, _body = *node
          # check if the class/module name matches the definee for the defs node
          return unless name == definee

          _, class_name = *definee
          add_offense(definee, :name, message(class_name, method_name))
        end

        def message(class_name, method_name)
          format(MSG, method_name, class_name, method_name)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.name, 'self') }
        end
      end
    end
  end
end
