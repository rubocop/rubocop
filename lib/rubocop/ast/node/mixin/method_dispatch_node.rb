# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that are a kind of method dispatch:
    # `send`, `csend`, `super`, `zsuper`, `yield`, `defined?`
    module MethodDispatchNode
      extend NodePattern::Macros
      include MethodIdentifierPredicates

      ARITHMETIC_OPERATORS = %i[+ - * / % **].freeze

      # The receiving node of the method dispatch.
      #
      # @return [Node, nil] the receiver of the dispatched method or `nil`
      def receiver
        node_parts[0]
      end

      # The name of the dispatched method as a symbol.
      #
      # @return [Symbol] the name of the dispatched method
      def method_name
        node_parts[1]
      end

      # An array containing the arguments of the dispatched method.
      #
      # @return [Array<Node>] the arguments of the dispatched method
      def arguments
        node_parts[2..-1]
      end

      # The `block` node associated with this method dispatch, if any.
      #
      # @return [BlockNode, nil] the `block` node associated with this method
      #                          call or `nil`
      def block_node
        parent if block_literal?
      end

      # Checks whether the dispatched method is a macro method. A macro method
      # is defined as a method that sits in a class, module, or block body and
      # has an implicit receiver.
      #
      # @note This does not include DSLs that use nested blocks, like RSpec
      #
      # @return [Boolean] whether the dispatched method is a macro method
      def macro?
        !receiver && macro_scope?
      end

      # Checks whether the dispatched method is an access modifier.
      #
      # @return [Boolean] whether the dispatched method is an access modifier
      def access_modifier?
        bare_access_modifier? || non_bare_access_modifier?
      end

      # Checks whether the dispatched method is a bare access modifier that
      # affects all methods defined after the macro.
      #
      # @return [Boolean] whether the dispatched method is a bare
      #                   access modifier
      def bare_access_modifier?
        macro? && bare_access_modifier_declaration?
      end

      # Checks whether the dispatched method is a non-bare access modifier that
      # affects only the method it receives.
      #
      # @return [Boolean] whether the dispatched method is a non-bare
      #                   access modifier
      def non_bare_access_modifier?
        macro? && non_bare_access_modifier_declaration?
      end

      # Checks whether the name of the dispatched method matches the argument
      # and has an implicit receiver.
      #
      # @param [Symbol, String] name the method name to check for
      # @return [Boolean] whether the method name matches the argument
      def command?(name)
        !receiver && method?(name)
      end

      # Checks whether the dispatched method is a setter method.
      #
      # @return [Boolean] whether the dispatched method is a setter
      def setter_method?
        loc.respond_to?(:operator) && loc.operator
      end
      alias assignment? setter_method?

      # Checks whether the dispatched method uses a dot to connect the
      # receiver and the method name.
      #
      # This is useful for comparison operators, which can be called either
      # with or without a dot, i.e. `foo == bar` or `foo.== bar`.
      #
      # @return [Boolean] whether the method was called with a connecting dot
      def dot?
        loc.respond_to?(:dot) && loc.dot && loc.dot.is?('.')
      end

      # Checks whether the dispatched method uses a double colon to connect the
      # receiver and the method name.
      #
      # @return [Boolean] whether the method was called with a connecting dot
      def double_colon?
        loc.respond_to?(:dot) && loc.dot && loc.dot.is?('::')
      end

      # Checks whether the *explicit* receiver of this method dispatch is
      # `self`.
      #
      # @return [Boolean] whether the receiver of this method dispatch is `self`
      def self_receiver?
        receiver && receiver.self_type?
      end

      # Checks whether the *explicit* receiver of this method dispatch is a
      # `const` node.
      #
      # @return [Boolean] whether the receiver of this method dispatch
      #                   is a `const` node
      def const_receiver?
        receiver && receiver.const_type?
      end

      # Checks whether the method dispatch is the implicit form of `#call`,
      # e.g. `foo.(bar)`.
      #
      # @return [Boolean] whether the method is the implicit form of `#call`
      def implicit_call?
        method?(:call) && !loc.selector
      end

      # Whether this method dispatch has an explicit block.
      #
      # @return [Boolean] whether the dispatched method has a block
      def block_literal?
        parent && parent.block_type? && eql?(parent.send_node)
      end

      # Checks whether this node is an arithmetic operation
      #
      # @return [Boolean] whether the dispatched method is an arithmetic
      #                   operation
      def arithmetic_operation?
        ARITHMETIC_OPERATORS.include?(method_name)
      end

      # Checks if this node is part of a chain of `def` modifiers.
      #
      # @example
      #
      #   private def foo; end
      #
      # @return [Boolean] whether the dispatched method is a `def` modifier
      def def_modifier?
        send_type? &&
          [self, *each_descendant(:send)].any?(&:adjacent_def_modifier?)
      end

      # Checks whether this is a lambda. Some versions of parser parses
      # non-literal lambdas as a method send.
      #
      # @return [Boolean] whether this method is a lambda
      def lambda?
        block_literal? && command?(:lambda)
      end

      # Checks whether this is a lambda literal (stabby lambda.)
      #
      # @example
      #
      #   -> (foo) { bar }
      #
      # @return [Boolean] whether this method is a lambda literal
      def lambda_literal?
        block_literal? && loc.expression && loc.expression.source == '->'
      end

      # Checks whether this is a unary operation.
      #
      # @example
      #
      #   -foo
      #
      # @return [Boolean] whether this method is a unary operation
      def unary_operation?
        return false unless loc.selector

        operator_method? && loc.expression.begin_pos == loc.selector.begin_pos
      end

      # Checks whether this is a binary operation.
      #
      # @example
      #
      #   foo + bar
      #
      # @return [Bookean] whether this method is a binary operation
      def binary_operation?
        return false unless loc.selector

        operator_method? && loc.expression.begin_pos != loc.selector.begin_pos
      end

      private

      def_node_matcher :macro_scope?, <<-PATTERN
        {^{({sclass class module block} ...) class_constructor?}
         ^^{({sclass class module block} ... (begin ...)) class_constructor?}
         ^#macro_kwbegin_wrapper?
         #root_node?}
      PATTERN

      # Check if a node's parent is a kwbegin wrapper within a macro scope
      #
      # @param parent [Node] parent of the node being checked
      #
      # @return [Boolean] true if the parent is a kwbegin in a macro scope
      def macro_kwbegin_wrapper?(parent)
        parent.kwbegin_type? && macro_scope?(parent)
      end

      # Check if a node does not have a parent
      #
      # @param node [Node]
      #
      # @return [Boolean] if the parent is nil
      def root_node?(node)
        node.parent.nil?
      end

      def_node_matcher :adjacent_def_modifier?, <<-PATTERN
        (send nil? _ ({def defs} ...))
      PATTERN

      def_node_matcher :bare_access_modifier_declaration?, <<-PATTERN
        (send nil? {:public :protected :private :module_function})
      PATTERN

      def_node_matcher :non_bare_access_modifier_declaration?, <<-PATTERN
        (send nil? {:public :protected :private :module_function} _)
      PATTERN
    end
  end
end
