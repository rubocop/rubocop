# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that are a kind of method dispatch:
    # `send`, `csend`, `super`, `zsuper`, `yield`
    module MethodDispatchNode
      extend NodePattern::Macros
      include MethodIdentifierPredicates

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

      # Checks whether the dispatched method is a macro method. A macro method
      # is defined as a method that sits in a class- or module body and has an
      # implicit receiver.
      #
      # @note This does not include DSLs that use nested blocks, like RSpec
      #
      # @return [Boolean] whether the dispatched method is a macro method
      def macro?
        !receiver && macro_scope?
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

      # The `block` node associated with this method dispatch, if any.
      #
      # @return [BlockNode, nil] the `block` node associated with this method
      #                          call or `nil`
      def block_node
        parent if block_literal?
      end

      private

      def_node_matcher :macro_scope?, <<-PATTERN
        {^({class module} ...)
         ^^({class module} ... (begin ...))}
      PATTERN

      def_node_matcher :prefixed_def_modifier?, <<-PATTERN
        (send nil _ ({def defs} ...))
      PATTERN
    end
  end
end
