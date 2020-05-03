# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Placing constants in the private section does not make them private,
      # which can be misleading
      #
      # Instead, you should explicitly declare a constant as private:
      #   `private_constant :MY_CONSTANT`
      #
      # @example
      #   # bad
      #   class Foo
      #     def public_stuff; end
      #
      #     private
      #     MY_CONSTANT = 7
      #     YOUR_CONSTANT = 21
      #   end
      #
      #   # good
      #   class Foo
      #     MY_CONSTANT = 7
      #     YOUR_CONSTANT = 21
      #
      #     private
      #     def private_stuff; end
      #   end
      #
      #   class Foo
      #     def public_stuff; end
      #
      #     private
      #     MY_CONSTANT = 7
      #     private_constant :MY_CONSTANT
      #   end
      #
      class PrivateConstant < Cop
        MSG = 'Avoid placing constants in private. ' \
              'This does not actually make a constant private.'

        def_node_matcher :private_or_protected_declaration?, <<~PATTERN
          (send nil? {:private :protected})
        PATTERN

        def_node_matcher :public_declaration?, <<~PATTERN
          (send nil? :public)
        PATTERN

        def_node_matcher :constant_assignment?, <<~PATTERN
          (casgn ...)
        PATTERN

        def on_class(node)
          klass_body = node.children.last
          return unless klass_body

          walk_over_klass(klass_body)
        end

        private

        def walk_over_klass(klass_body)
          current_block = 'public'
          klass_body.children.each do |child|
            if private_or_protected_declaration?(child)
              current_block = 'private'
            elsif public_declaration?(child)
              current_block = 'public'
            elsif constant_assignment?(child)
              if current_block == 'private' &&
                 !explicit_private_declaration(child)
                add_offense(child)
              end
            end
          end
        end

        def explicit_private_declaration(node)
          constant_name = node.children[1]
          node.parent.children.any? do |n|
            NodePattern.new(
              "(send nil? :private_constant (:sym :#{constant_name}))"
            ).match(n)
          end
        end
      end
    end
  end
end
