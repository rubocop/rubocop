# encoding: utf-8
module RuboCop
  module Cop
    module Lint
      # This cop checks for access modifiers without any code.
      #
      # @example
      #   class Foo
      #     private # This is useless
      #
      #     def self.some_method
      #     end
      #   end
      class UselessAccessModifier < Cop
        include AccessModifierNode

        MSG = 'Useless `%s` access modifier.'

        def on_class(node)
          _name, _base_class, body = *node
          return unless body

          body_nodes = body.type == :begin ? body.children : [body]

          body_nodes.each do |child_node|
            check_for_access_modifier(child_node) ||
              check_for_instance_method(child_node)
          end

          add_offense_for_access_modifier
        end

        private

        def add_offense_for_access_modifier
          return unless @access_modifier_node

          _, modifier = *@access_modifier_node
          message = format(MSG, modifier)
          add_offense(@access_modifier_node, :expression, message)
        end

        def check_for_instance_method(node)
          return unless node.type == :def || node.type == :send

          @access_modifier_node = nil
        end

        def check_for_access_modifier(node)
          return unless modifier_node?(node)

          add_offense_for_access_modifier
          @access_modifier_node = node
        end
      end
    end
  end
end
