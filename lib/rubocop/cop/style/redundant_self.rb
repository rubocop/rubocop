# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant uses of `self`.
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
      # otherwise. Also allows the use of `self.it` without arguments in blocks,
      # as in `0.times { self.it }`, following `Lint/ItWithoutArgumentsInBlock` cop.
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
          [Layout::DotPosition]
        end

        def initialize(config = nil, options = nil)
          super
          @allowed_send_nodes = Set.new.compare_by_identity
        end

        # Assignment of self.x

        def on_or_asgn(node)
          allow_self(node.lhs)
        end
        alias on_and_asgn on_or_asgn

        def on_op_asgn(node)
          allow_self(node.lhs)
        end

        def on_send(node)
          return unless node.self_receiver? && regular_method_call?(node)
          return if multiple_assignment_target?(node)
          return if allowed_send_node?(node)
          return if it_method_in_block?(node)

          add_offense(node.receiver) do |corrector|
            corrector.remove(node.receiver)
            corrector.remove(node.loc.dot)
          end
        end

        private

        def multiple_assignment_target?(node)
          return false unless (parent = node.parent)

          parent = parent.parent if parent.splat_type?

          parent.mlhs_type?
        end

        def allowed_send_node?(node)
          @allowed_send_nodes.include?(node) ||
            processed_source.variable_analysis.variable_visible?(node.method_name, node) ||
            assigned_in_conditional?(node) ||
            KERNEL_METHODS.include?(node.method_name)
        end

        # In `a = self.a if self.a` the variable is declared in front of the
        # condition. The same condition in a regular `if` is accepted as well.
        def assigned_in_conditional?(node)
          node.each_ancestor(:if, :while, :until).any? do |conditional|
            within?(node, conditional.condition) &&
              conditional.each_descendant(:lvasgn).any? { |asgn| asgn.name == node.method_name }
          end
        end

        def within?(node, ancestor)
          node.equal?(ancestor) || node.each_ancestor.any? { |other| other.equal?(ancestor) }
        end

        # Respects `Lint/ItWithoutArgumentsInBlock` cop and the following Ruby 3.3's warning:
        #
        # $ ruby -e '0.times { begin; it; end }'
        # -e:1: warning: `it` calls without arguments will refer to the first block param in
        # Ruby 3.4; use it() or self.it
        #
        def it_method_in_block?(node)
          return false unless node.method?(:it)
          return false unless (block_node = node.each_ancestor(:block).first)
          return false unless block_node.arguments.empty_and_without_delimiters?

          node.arguments.empty? && !node.block_literal?
        end

        def regular_method_call?(node)
          !(node.operator_method? ||
            KEYWORDS.include?(node.method_name) ||
            node.camel_case_method? ||
            node.setter_method? ||
            node.implicit_call?)
        end

        def allow_self(node)
          return unless node.send_type? && node.self_receiver?

          @allowed_send_nodes.add(node)
        end
      end
    end
  end
end
