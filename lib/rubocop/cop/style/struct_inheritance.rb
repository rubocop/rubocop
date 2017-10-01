# frozen_string_literal: true

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
        MSG = "Don't extend an instance initialized by `Struct.new`.".freeze

        def on_class(node)
          _name, superclass, _body = *node
          return unless struct_constructor?(superclass)

          add_offense(node, superclass.source_range)
        end

        def_node_matcher :struct_constructor?, <<-PATTERN
           {(send (const nil? :Struct) :new ...)
            (block (send (const nil? :Struct) :new ...) ...)}
        PATTERN
      end
    end
  end
end
