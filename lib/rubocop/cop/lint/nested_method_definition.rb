# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for nested method definitions.
      #
      # @example
      #
      #   # bad
      #
      #   # `bar` definition actually produces methods in the same scope
      #   # as the outer `foo` method. Furthermore, the `bar` method
      #   # will be redefined every time `foo` is invoked.
      #   def foo
      #     def bar
      #     end
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     bar = -> { puts 'hello' }
      #     bar.call
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     self.class.class_eval do
      #       def bar
      #       end
      #     end
      #   end
      #
      #   def foo
      #     self.class.module_exec do
      #       def bar
      #       end
      #     end
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     class << self
      #       def bar
      #       end
      #     end
      #   end
      class NestedMethodDefinition < Base
        MSG = 'Method definitions must not be nested. Use `lambda` instead.'

        def on_def(node)
          subject, = *node
          return if node.defs_type? && subject.lvar_type?

          def_ancestor = node.each_ancestor(:def, :defs).first
          return unless def_ancestor

          within_scoping_def =
            node.each_ancestor(:block, :sclass).any? do |ancestor|
              scoping_method_call?(ancestor)
            end

          add_offense(node) if def_ancestor && !within_scoping_def
        end
        alias on_defs on_def

        private

        def scoping_method_call?(child)
          child.sclass_type? || eval_call?(child) || exec_call?(child) ||
            class_or_module_or_struct_new_call?(child)
        end

        # @!method eval_call?(node)
        def_node_matcher :eval_call?, <<~PATTERN
          (block (send _ {:instance_eval :class_eval :module_eval} ...) ...)
        PATTERN

        # @!method exec_call?(node)
        def_node_matcher :exec_call?, <<~PATTERN
          (block (send _ {:instance_exec :class_exec :module_exec} ...) ...)
        PATTERN

        # @!method class_or_module_or_struct_new_call?(node)
        def_node_matcher :class_or_module_or_struct_new_call?, <<~PATTERN
          (block (send (const {nil? cbase} {:Class :Module :Struct}) :new ...) ...)
        PATTERN
      end
    end
  end
end
