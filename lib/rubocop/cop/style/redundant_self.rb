# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant uses of `self`.
      #
      # The usage of `self` is only needed when:
      #
      # * Sending a message to same object with zero arguments in
      #   presence of a method name clash with an argument or a local
      #   variable.
      #
      # * Calling an attribute writer to prevent a local variable assignment.
      #
      # Note, with using explicit self you can only send messages with public or
      # protected scope, you cannot send private messages this way.
      #
      # Note we allow uses of `self` with operators because it would be awkward
      # otherwise.
      #
      # @example
      #
      #   # bad
      #   def foo(bar)
      #     self.baz
      #   end
      #
      #   # good
      #   def foo(bar)
      #     self.bar  # Resolves name clash with the argument.
      #   end
      #
      #   def foo
      #     bar = 1
      #     self.bar  # Resolves name clash with the local variable.
      #   end
      #
      #   def foo
      #     %w[x y z].select do |bar|
      #       self.bar == bar  # Resolves name clash with argument of the block.
      #     end
      #   end
      class RedundantSelf < Base
        extend AutoCorrector

        MSG = 'Redundant `self` detected.'
        KERNEL_METHODS = Kernel.methods(false)
        KEYWORDS = %i[alias and begin break case class def defined? do
                      else elsif end ensure false for if in module
                      next nil not or redo rescue retry return self
                      super then true undef unless until when while
                      yield __FILE__ __LINE__ __ENCODING__].freeze

        def self.autocorrect_incompatible_with
          [ColonMethodCall]
        end

        def initialize(config = nil, options = nil)
          super
          @allowed_send_nodes = []
          @local_variables_scopes = Hash.new { |hash, key| hash[key] = [] }.compare_by_identity
        end

        # Assignment of self.x

        def on_or_asgn(node)
          lhs, _rhs = *node
          allow_self(lhs)
        end
        alias on_and_asgn on_or_asgn

        def on_op_asgn(node)
          lhs, _op, _rhs = *node
          allow_self(lhs)
        end

        # Using self.x to distinguish from local variable x

        def on_def(node)
          add_scope(node)
        end
        alias on_defs on_def

        def on_args(node)
          node.children.each { |arg| on_argument(arg) }
        end

        def on_blockarg(node)
          on_argument(node)
        end

        def on_masgn(node)
          lhs, rhs = *node
          lhs.children.each do |child|
            add_lhs_to_local_variables_scopes(rhs, child.to_a.first)
          end
        end

        def on_lvasgn(node)
          lhs, rhs = *node
          add_lhs_to_local_variables_scopes(rhs, lhs)
        end

        def on_send(node)
          return unless node.self_receiver? && regular_method_call?(node)
          return if node.parent&.mlhs_type?

          return if allowed_send_node?(node)

          add_offense(node) do |corrector|
            corrector.remove(node.receiver)
            corrector.remove(node.loc.dot)
          end
        end

        def on_block(node)
          add_scope(node, @local_variables_scopes[node])
        end

        private

        def add_scope(node, local_variables = [])
          node.each_descendant do |child_node|
            @local_variables_scopes[child_node] = local_variables
          end
        end

        def allowed_send_node?(node)
          @allowed_send_nodes.include?(node) ||
            @local_variables_scopes[node].include?(node.method_name) ||
            node.each_ancestor.any? do |ancestor|
              @local_variables_scopes[ancestor].include?(node.method_name)
            end ||
            KERNEL_METHODS.include?(node.method_name)
        end

        def regular_method_call?(node)
          !(node.operator_method? ||
            KEYWORDS.include?(node.method_name) ||
            node.camel_case_method? ||
            node.setter_method? ||
            node.implicit_call?)
        end

        def on_argument(node)
          if node.mlhs_type?
            on_args(node)
          else
            name, = *node
            @local_variables_scopes[node] << name
          end
        end

        def allow_self(node)
          return unless node.send_type? && node.self_receiver?

          @allowed_send_nodes << node
        end

        def add_lhs_to_local_variables_scopes(rhs, lhs)
          if rhs&.send_type? && !rhs.arguments.empty?
            rhs.arguments.each do |argument|
              @local_variables_scopes[argument] << lhs
            end
          else
            @local_variables_scopes[rhs] << lhs
          end
        end
      end
    end
  end
end
