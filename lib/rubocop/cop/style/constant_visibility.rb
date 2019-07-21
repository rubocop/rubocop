# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that constants defined in classes and modules have
      # an explicit visibility declaration. By default, Ruby makes all class-
      # and module constants public, which litters the public API of the
      # class or module. Explicitly declaring a visibility makes intent more
      # clear, and prevents outside actors from touching private state.
      #
      # @example
      #
      #   # bad
      #   class Foo
      #     BAR = 42
      #     BAZ = 43
      #   end
      #
      #   # good
      #   class Foo
      #     BAR = 42
      #     private_constant :BAR
      #
      #     BAZ = 43
      #     public_constant :BAZ
      #   end
      #
      class ConstantVisibility < Cop
        MSG = 'Explicitly make `%<constant_name>s` public or private using ' \
              'either `#public_constant` or `#private_constant`.'

        def on_casgn(node)
          return unless class_or_module_scope?(node)
          return if visibility_declaration?(node)

          add_offense(node)
        end

        private

        def message(node)
          _namespace, constant_name, _value = *node

          format(MSG, constant_name: constant_name)
        end

        def class_or_module_scope?(node)
          return false unless node.parent

          case node.parent.type
          when :begin
            class_or_module_scope?(node.parent)
          when :class, :module
            true
          end
        end

        def visibility_declaration?(node)
          _namespace, constant_name, _value = *node

          node.parent.each_child_node(:send).any? do |child|
            visibility_declaration_for?(child, constant_name)
          end
        end

        def_node_matcher :visibility_declaration_for?, <<~PATTERN
          (send nil? {:public_constant :private_constant} ({sym str} #match_name?(%1)))
        PATTERN

        def match_name?(name, constant_name)
          name.to_sym == constant_name.to_sym
        end
      end
    end
  end
end
