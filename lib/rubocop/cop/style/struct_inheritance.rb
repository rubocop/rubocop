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
        include RangeHelp

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

        def autocorrect(class_node)
          lambda do |corrector|
            return nil if struct_definition_has_block?(class_node)

            remove_class_keyword(class_node, corrector)

            corrector.replace(class_node.loc.operator, '=')

            transform_class_body(class_node, corrector)
          end
        end

        private

        def struct_definition_has_block?(class_node)
          class_node.parent_class.is_a?(RuboCop::AST::BlockNode)
        end

        def remove_class_keyword(class_node, corrector)
          corrector.remove(
            range_with_surrounding_space(
              range: class_node.loc.keyword,
              side: :right
            )
          )
        end

        def transform_class_body(class_node, corrector)
          body = class_node.body

          if body
            corrector.insert_after(class_node.parent_class.source_range, ' do')
          else
            corrector.remove(
              range_with_surrounding_space(
                range: class_node.loc.end,
                side: :right
              )
            )
          end
        end
      end
    end
  end
end
