# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for useless constant scoping. Private constants must be defined using
      # `private_constant`. Even if `private` access modifier is used, it is public scope despite
      # its appearance.
      #
      # It does not support autocorrection due to behavior change and multiple ways to fix it.
      # Or a public constant may be intended.
      #
      # Constant assignments that define classes or modules via `Class.new`, `Module.new`,
      # `Struct.new`, or `Data.define` are allowed. Those forms are class and module definitions
      # written with assignment syntax, and match the common practice of placing nested
      # `class` / `module` bodies after `private` without intending private constant visibility.
      #
      # @example
      #
      #   # bad
      #   class Foo
      #     private
      #     PRIVATE_CONST = 42
      #   end
      #
      #   # good
      #   class Foo
      #     PRIVATE_CONST = 42
      #     private_constant :PRIVATE_CONST
      #   end
      #
      #   # good
      #   class Foo
      #     PUBLIC_CONST = 42 # If private scope is not intended.
      #   end
      #
      #   # good - class/module definitions via assignment, same as nested `class`/`module`
      #   class Foo
      #     private
      #
      #     def some_private_method
      #     end
      #
      #     MyClass = Class.new
      #     MyModule = Module.new
      #     MyStruct = Struct.new(:name)
      #     MyData = Data.define(:name)
      #   end
      #
      class UselessConstantScoping < Base
        MSG = 'Useless `private` access modifier for constant scope.'

        # @!method private_constants(node)
        def_node_matcher :private_constants, <<~PATTERN
          (send nil? :private_constant $...)
        PATTERN

        # Matches class/module-like constant assignments. Nested `class` / `module`
        # keyword definitions are not visited by this cop; these assignment forms are
        # the equivalent syntax and should be treated the same way.
        # @!method class_or_module_definition_assignment?(node)
        def_node_matcher :class_or_module_definition_assignment?, <<~PATTERN
          {
            (send (const {nil? cbase} {:Class :Module :Struct}) :new ...)
            (send (const {nil? cbase} :Data) :define ...)
            (any_block
              {
                (send (const {nil? cbase} {:Class :Module :Struct}) :new ...)
                (send (const {nil? cbase} :Data) :define ...)
              }
              ...)
          }
        PATTERN

        def on_casgn(node)
          return unless after_private_modifier?(node.left_siblings)
          return if private_constantize?(node.right_siblings, node.name)
          return if class_or_module_definition_assignment?(node.expression)

          add_offense(node)
        end

        private

        def after_private_modifier?(left_siblings)
          access_modifier_candidates = left_siblings.compact.select do |left_sibling|
            left_sibling.respond_to?(:bare_access_modifier?) && left_sibling.bare_access_modifier?
          end

          return false if access_modifier_candidates.empty?

          access_modifier_candidates.last.command?(:private)
        end

        def private_constantize?(right_siblings, const_value)
          private_constant_arguments = right_siblings.map { |node| private_constants(node) }

          private_constant_values = private_constant_arguments.flatten.filter_map do |constant|
            constant.value.to_sym if constant.respond_to?(:value)
          end

          private_constant_values.include?(const_value)
        end
      end
    end
  end
end
