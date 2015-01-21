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

          add_offense(node, superclass.loc.expression, MSG)
        end

        private

        def struct_constructor?(node)
          if node && node.send_type?
            receiver, method_name = *node

            receiver &&
              receiver.const_type? &&
              receiver.children.last == :Struct &&
              method_name == :new
          else
            false
          end
        end
      end
    end
  end
end
