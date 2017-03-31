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
      #     self.class_eval do
      #       def bar
      #       end
      #     end
      #   end
      #
      #   def foo
      #     self.module_exec do
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
      class NestedMethodDefinition < Cop
        include OnMethodDef
        extend RuboCop::NodePattern::Macros

        MSG = 'Method definitions must not be nested. ' \
              'Use `lambda` instead.'.freeze

        def on_method_def(node, _method_name, _args, _body)
          find_nested_defs(node) do |nested_def_node|
            add_offense(nested_def_node, :expression)
          end
        end

        def find_nested_defs(node, &block)
          node.each_child_node do |child|
            if child.def_type?
              yield child
            elsif child.defs_type?
              subject, = *child
              next if subject.lvar_type?
              yield child
            elsif !scoping_method_call?(child)
              find_nested_defs(child, &block)
            end
          end
        end

        private

        def scoping_method_call?(child)
          eval_call?(child) || exec_call?(child) || child.sclass_type? ||
            class_or_module_or_struct_new_call?(child)
        end

        def_node_matcher :eval_call?, <<-PATTERN
          (block (send _ {:instance_eval :class_eval :module_eval} ...) ...)
        PATTERN

        def_node_matcher :exec_call?, <<-PATTERN
          (block (send _ {:instance_exec :class_exec :module_exec} ...) ...)
        PATTERN

        def_node_matcher :class_or_module_or_struct_new_call?, <<-PATTERN
          (block (send (const nil {:Class :Module :Struct}) :new ...) ...)
        PATTERN
      end
    end
  end
end
