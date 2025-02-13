# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      class PrivateConstant < Base
        # Placing constants in the `private` section does not make them private, which is misleading.
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

        MSG = 'Avoid placing constants in private. This does not actually make a constant private.'

        # @!method private_or_protected_declaration?(node)
        def_node_matcher :private_or_protected_declaration?, <<~PATTERN
          (send nil? {:private :protected})
        PATTERN

        # @!method public_declaration?(node)
        def_node_matcher :public_declaration?, <<~PATTERN
          (send nil? :public)
        PATTERN

        # @!method constant_assignment?(node)
        def_node_matcher :constant_assignment?, <<~PATTERN
          (casgn ...)
        PATTERN

        def on_class(node)
          return unless node.children.last

          current_visibility = :public
          private_constants = []
          private_constant_declarations = Set.new

          body = node.children.last
          return unless body.begin_type?

          body.children.each do |child|
            case child.type
            when :send
              if private_or_protected_declaration?(child)
                current_visibility = :private
              elsif public_declaration?(child)
                current_visibility = :public
              elsif child.method?(:private_constant)
                private_constant_declarations.add(child.first_argument.children[0])
              end
            when :casgn
              private_constants << child if current_visibility == :private
            end
          end

          private_constants.each do |const_node|
            add_offense(const_node) unless private_constant_declarations.include?(const_node.children[1])
          end
        end
      end
    end
  end
end
