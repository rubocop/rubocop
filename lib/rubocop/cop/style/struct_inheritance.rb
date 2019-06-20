# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for inheritance from Struct.new.
      #
      # @example
      #   # bad
      #   class Person < Struct.new(:first_name, :last_name)
      #     def age
      #       42
      #     end
      #   end
      #
      #   # good
      #   Person = Struct.new(:first_name, :last_name) do
      #     def age
      #       42
      #     end
      #   end
      class StructInheritance < Cop
        MSG = "Don't extend an instance initialized by `Struct.new`. " \
              'Use a block to customize the struct.'

        def on_class(node)
          return unless struct_constructor?(node.parent_class)

          add_offense(node, location: node.parent_class.source_range)
        end

        def_node_matcher :struct_constructor?, <<~PATTERN
          {(send (const nil? :Struct) :new ...)
           (block (send (const nil? :Struct) :new ...) ...)}
        PATTERN
      end
    end
  end
end
