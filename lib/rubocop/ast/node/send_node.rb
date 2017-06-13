# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `send` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `send` nodes within RuboCop.
    class SendNode < Node
      include ParameterizedNode
      include MethodIdentifierPredicates

      ENUMERATOR_METHODS = %i[collect collect_concat detect downto each
                              find find_all find_index inject loop map!
                              map reduce reject reject! reverse_each select
                              select! times upto].freeze

      # The receiving node of the method invocation.
      #
      # @return [Node, nil] the receiver of the invoked method or `nil`
      def receiver
        node_parts[0]
      end

      # The name of the invoked method called as a symbol.
      #
      # @return [Symbol] the name of the invoked method
      def method_name
        node_parts[1]
      end

      # An array containing the arguments of the method invocation.
      #
      # @return [Array<Node>] the arguments of the method invocation
      def arguments
        node_parts[2..-1]
      end

      # Checks whether the method is a macro method. A macro method is defined
      # as a method that sits in a class- or module body and has an implicit
      # receiver.
      #
      # @note This does not include DSLs that use nested blocks, like RSpec
      #
      # @return [Boolean] whether the method is a macro method
      def macro?
        !receiver && macro_scope?
      end

      # Checks whether the method name matches the argument and has an
      # implicit receiver.
      #
      # @param [Symbol, String] name the method name to check for
      # @return [Boolean] whether the method name matches the argument
      def command?(name)
        !receiver && method?(name)
      end

      # Checks whether the invoked method is a setter method.
      #
      # @return [Boolean] whether the invoked method is a setter
      def setter_method?
        loc.operator
      end

      # Checks whether the method call uses a dot to connect the receiver and
      # the method name.
      #
      # This is useful for comparison operators, which can be called either
      # with or without a dot, i.e. `foo == bar` or `foo.== bar`.
      #
      # @return [Boolean] whether the method was called with a connecting dot
      def dot?
        loc.dot && loc.dot.is?('.')
      end

      # Checks whether the method call uses a double colon to connect the
      # receiver and the method name.
      #
      # @return [Boolean] whether the method was called with a connecting dot
      def double_colon?
        loc.dot && loc.dot.is?('::')
      end

      # Checks whether the *explicit* receiver of this method invocation is
      # `self`.
      #
      # @return [Boolean] whether the receiver of this method invocation
      #                   is `self`
      def self_receiver?
        receiver && receiver.self_type?
      end

      # Checks whether the *explicit* receiver of this method invocation is a
      # `const` node.
      #
      # @return [Boolean] whether the receiver of this method invocation
      #                   is a `const` node
      def const_receiver?
        receiver && receiver.const_type?
      end

      # Checks whether the method call is of the implicit form of `#call`,
      # e.g. `foo.(bar)`.
      #
      # @return [Boolean] whether the method is an implicit form of `#call`
      def implicit_call?
        method_name == :call && !loc.selector
      end

      # Whether this method invocation has an explicit block.
      #
      # @return [Boolean] whether the invoked method has a block
      def block_literal?
        parent && parent.block_type? && eql?(parent.send_node)
      end

      # The block node associated with this method call, if any.
      #
      # @return [BlockNode, nil] the `block` node associated with this method
      #                          call or `nil`
      def block_node
        parent if block_literal?
      end

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array] the different parts of the `send` node
      def node_parts
        to_a
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
