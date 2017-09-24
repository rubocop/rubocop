# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for redundant access modifiers, including those with no
      # code, those which are repeated, and leading `public` modifiers in a
      # class or module body. Conditionally-defined methods are considered as
      # always being defined, and thus access modifiers guarding such methods
      # are not redundant.
      #
      # @example
      #
      #   class Foo
      #     public # this is redundant (default access is public)
      #
      #     def method
      #     end
      #
      #     private # this is not redundant (a method is defined)
      #     def method2
      #     end
      #
      #     private # this is redundant (no following methods are defined)
      #   end
      #
      # @example
      #
      #   class Foo
      #     # The following is not redundant (conditionally defined methods are
      #     # considered as always defining a method)
      #     private
      #
      #     if condition?
      #       def method
      #       end
      #     end
      #
      #     protected # this is not redundant (method is defined)
      #
      #     define_method(:method2) do
      #     end
      #
      #     protected # this is redundant (repeated from previous modifier)
      #
      #     [1,2,3].each do |i|
      #       define_method("foo#{i}") do
      #       end
      #     end
      #
      #     # The following is redundant (methods defined on the class'
      #     # singleton class are not affected by the public modifier)
      #     public
      #
      #     def self.method3
      #     end
      #   end
      #
      # @example
      #   # Lint/UselessAccessModifier:
      #   #   ContextCreatingMethods:
      #   #     - concerning
      #   require 'active_support/concern'
      #   class Foo
      #     concerning :Bar do
      #       def some_public_method
      #       end
      #
      #       private
      #
      #       def some_private_method
      #       end
      #     end
      #
      #     # this is not redundant because `concerning` created its own context
      #     private
      #
      #     def some_other_private_method
      #     end
      #   end
      #
      # @example
      #   # Lint/UselessAccessModifier:
      #   #   MethodCreatingMethods:
      #   #     - delegate
      #   require 'active_support/core_ext/module/delegation'
      #   class Foo
      #     # this is not redundant because `delegate` creates methods
      #     private
      #
      #     delegate :method_a, to: :method_b
      #   end
      class UselessAccessModifier < Cop
        MSG = 'Useless `%s` access modifier.'.freeze

        def on_class(node)
          check_node(node.children[2]) # class body
        end

        def on_module(node)
          check_node(node.children[1]) # module body
        end

        def on_block(node)
          return unless eval_call?(node)

          check_node(node.body)
        end

        def on_sclass(node)
          check_node(node.children[1]) # singleton class body
        end

        private

        def_node_matcher :static_method_definition?, <<-PATTERN
          {def (send nil? {:attr :attr_reader :attr_writer :attr_accessor} ...)}
        PATTERN

        def_node_matcher :dynamic_method_definition?, <<-PATTERN
          {(send nil? :define_method ...) (block (send nil? :define_method ...) ...)}
        PATTERN

        def_node_matcher :class_or_instance_eval?, <<-PATTERN
          (block (send _ {:class_eval :instance_eval}) ...)
        PATTERN

        def_node_matcher :class_or_module_or_struct_new_call?, <<-PATTERN
          (block (send (const nil? {:Class :Module :Struct}) :new ...) ...)
        PATTERN

        def check_node(node)
          return if node.nil?

          if node.begin_type?
            check_scope(node)
          elsif node.send_type? && node.access_modifier?
            add_offense(node, message: format(MSG, node.method_name))
          end
        end

        def check_scope(node)
          cur_vis, unused = check_child_nodes(node, nil, :public)

          add_offense(unused, message: format(MSG, cur_vis)) if unused
        end

        def check_child_nodes(node, unused, cur_vis)
          node.child_nodes.each do |child|
            if child.send_type? && child.access_modifier?
              cur_vis, unused =
                check_new_visibility(child, unused, child.method_name, cur_vis)
            elsif method_definition?(child)
              unused = nil
            elsif start_of_new_scope?(child)
              check_scope(child)
            elsif !child.defs_type?
              cur_vis, unused = check_child_nodes(child, unused, cur_vis)
            end
          end

          [cur_vis, unused]
        end

        def check_new_visibility(node, unused, new_vis, cur_vis)
          # does this modifier just repeat the existing visibility?
          if new_vis == cur_vis
            add_offense(node, message: format(MSG, cur_vis))
          else
            # was the previous modifier never applied to any defs?
            add_offense(unused, message: format(MSG, cur_vis)) if unused
            # once we have already warned about a certain modifier, don't
            # warn again even if it is never applied to any method defs
            unused = node
          end

          [new_vis, unused]
        end

        def method_definition?(child)
          static_method_definition?(child) ||
            dynamic_method_definition?(child) ||
            any_method_definition?(child)
        end

        def any_method_definition?(child)
          cop_config.fetch('MethodCreatingMethods', []).any? do |m|
            matcher_name = "#{m}_method?".to_sym
            unless respond_to?(matcher_name)
              self.class.def_node_matcher matcher_name, <<-PATTERN
                {def (send nil? :#{m} ...)}
              PATTERN
            end

            send(matcher_name, child)
          end
        end

        def start_of_new_scope?(child)
          child.module_type? || child.class_type? ||
            child.sclass_type? || eval_call?(child)
        end

        def eval_call?(child)
          class_or_instance_eval?(child) ||
            class_or_module_or_struct_new_call?(child) ||
            any_context_creating_methods?(child)
        end

        def any_context_creating_methods?(child)
          cop_config.fetch('ContextCreatingMethods', []).any? do |m|
            matcher_name = "#{m}_block?".to_sym
            unless respond_to?(matcher_name)
              self.class.def_node_matcher matcher_name, <<-PATTERN
                (block (send {nil? const} {:#{m}} ...) ...)
              PATTERN
            end

            send(matcher_name, child)
          end
        end
      end
    end
  end
end
