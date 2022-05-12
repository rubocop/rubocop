# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for redundant access modifiers, including those with no
      # code, those which are repeated, and leading `public` modifiers in a
      # class or module body. Conditionally-defined methods are considered as
      # always being defined, and thus access modifiers guarding such methods
      # are not redundant.
      #
      # This cop has `ContextCreatingMethods` option. The default setting value
      # is an empty array that means no method is specified.
      # This setting is an array of methods which, when called, are known to
      # create its own context in the module's current access context.
      #
      # It also has `MethodCreatingMethods` option. The default setting value
      # is an empty array that means no method is specified.
      # This setting is an array of methods which, when called, are known to
      # create other methods in the module's current access context.
      #
      # @example
      #   # bad
      #   class Foo
      #     public # this is redundant (default access is public)
      #
      #     def method
      #     end
      #   end
      #
      #   # bad
      #   class Foo
      #     # The following is redundant (methods defined on the class'
      #     # singleton class are not affected by the public modifier)
      #     public
      #
      #     def self.method3
      #     end
      #   end
      #
      #   # bad
      #   class Foo
      #     protected
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
      #   end
      #
      #   # bad
      #   class Foo
      #     private # this is redundant (no following methods are defined)
      #   end
      #
      #   # good
      #   class Foo
      #     private # this is not redundant (a method is defined)
      #
      #     def method2
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     # The following is not redundant (conditionally defined methods are
      #     # considered as always defining a method)
      #     private
      #
      #     if condition?
      #       def method
      #       end
      #     end
      #   end
      #
      #   # good
      #   class Foo
      #     protected # this is not redundant (a method is defined)
      #
      #     define_method(:method2) do
      #     end
      #   end
      #
      # @example ContextCreatingMethods: concerning
      #   # Lint/UselessAccessModifier:
      #   #   ContextCreatingMethods:
      #   #     - concerning
      #
      #   # good
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
      # @example MethodCreatingMethods: delegate
      #   # Lint/UselessAccessModifier:
      #   #   MethodCreatingMethods:
      #   #     - delegate
      #
      #   # good
      #   require 'active_support/core_ext/module/delegation'
      #   class Foo
      #     # this is not redundant because `delegate` creates methods
      #     private
      #
      #     delegate :method_a, to: :method_b
      #   end
      class UselessAccessModifier < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Useless `%<current>s` access modifier.'

        def on_class(node)
          check_node(node.body)
        end
        alias on_module on_class
        alias on_sclass on_class

        def on_block(node)
          return unless eval_call?(node)

          check_node(node.body)
        end

        private

        def autocorrect(corrector, node)
          range = range_by_whole_lines(node.source_range, include_final_newline: true)

          corrector.remove(range)
        end

        # @!method static_method_definition?(node)
        def_node_matcher :static_method_definition?, <<~PATTERN
          {def (send nil? {:attr :attr_reader :attr_writer :attr_accessor} ...)}
        PATTERN

        # @!method dynamic_method_definition?(node)
        def_node_matcher :dynamic_method_definition?, <<~PATTERN
          {(send nil? :define_method ...) (block (send nil? :define_method ...) ...)}
        PATTERN

        # @!method class_or_instance_eval?(node)
        def_node_matcher :class_or_instance_eval?, <<~PATTERN
          (block (send _ {:class_eval :instance_eval}) ...)
        PATTERN

        # @!method class_or_module_or_struct_new_call?(node)
        def_node_matcher :class_or_module_or_struct_new_call?, <<~PATTERN
          (block (send (const {nil? cbase} {:Class :Module :Struct}) :new ...) ...)
        PATTERN

        def check_node(node)
          return if node.nil?

          if node.begin_type?
            check_scope(node)
          elsif node.send_type? && node.bare_access_modifier?
            add_offense(node, message: format(MSG, current: node.method_name)) do |corrector|
              autocorrect(corrector, node)
            end
          end
        end

        def access_modifier?(node)
          node.bare_access_modifier? || node.method?(:private_class_method)
        end

        def check_scope(node)
          cur_vis, unused = check_child_nodes(node, nil, :public)
          return unless unused

          add_offense(unused, message: format(MSG, current: cur_vis)) do |corrector|
            autocorrect(corrector, unused)
          end
        end

        def check_child_nodes(node, unused, cur_vis)
          node.child_nodes.each do |child|
            if child.send_type? && access_modifier?(child)
              cur_vis, unused = check_send_node(child, cur_vis, unused)
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

        def check_send_node(node, cur_vis, unused)
          if node.bare_access_modifier?
            check_new_visibility(node, unused, node.method_name, cur_vis)
          elsif node.method?(:private_class_method) && !node.arguments?
            add_offense(node, message: format(MSG, current: node.method_name)) do |corrector|
              autocorrect(corrector, node)
            end
            [cur_vis, unused]
          end
        end

        def check_new_visibility(node, unused, new_vis, cur_vis)
          # does this modifier just repeat the existing visibility?
          if new_vis == cur_vis
            add_offense(node, message: format(MSG, current: cur_vis)) do |corrector|
              autocorrect(corrector, node)
            end
          else
            # was the previous modifier never applied to any defs?
            if unused
              add_offense(unused, message: format(MSG, current: cur_vis)) do |corrector|
                autocorrect(corrector, unused)
              end
            end
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
              self.class.def_node_matcher matcher_name, <<~PATTERN
                {def (send nil? :#{m} ...)}
              PATTERN
            end

            public_send(matcher_name, child)
          end
        end

        def start_of_new_scope?(child)
          child.module_type? || child.class_type? || child.sclass_type? || eval_call?(child)
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
              self.class.def_node_matcher matcher_name, <<~PATTERN
                (block (send {nil? const} {:#{m}} ...) ...)
              PATTERN
            end

            public_send(matcher_name, child)
          end
        end
      end
    end
  end
end
