# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for inheritance from Struct.new.
      #
      # @example
      #   # bad
      #   class Person < Struct.new(:first_name, :last_name)
      #   end
      #
      #   # good
      #   Person = Struct.new(:first_name, :last_name)
      class StructInheritance < Cop
        MSG = "Don't extend an instance initialized by `Struct.new`."

        def on_class(node)
          _name, superclass, _body = *node
          return unless struct_constructor?(superclass)

          add_offense(node, superclass.source_range, MSG)
        end

        private

        def struct_constructor?(node)
          return false unless node

          send_node = node.block_type? ? node.children.first : node
          return false unless send_node.send_type?

          receiver, method_name = *send_node

          receiver &&
            receiver.const_type? &&
            receiver.children.last == :Struct &&
            method_name == :new
        end
      end
    end
  end
end
