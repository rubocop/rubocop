# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that are parameterized:
    # `send`, `super`, `zsuper` ...
    module ParameterizedNode
      # Checks whether this super invocation's arguments are wrapped in
      # parentheses.
      #
      # @return [Boolean] whether this super invocation's arguments are
      #                   wrapped in parentheses
      def parenthesized?
        loc.end && loc.end.is?(')')
      end

      # A shorthand for getting the first argument of the method invocation.
      # Equivalent to `arguments.first`.
      #
      # @return [Node, nil] the first argument of the method invocation,
      #                     or `nil` if there are no arguments
      def first_argument
        arguments[0]
      end

      # A shorthand for getting the last argument of the method invocation.
      # Equivalent to `arguments.last`.
      #
      # @return [Node, nil] the last argument of the method invocation,
      #                     or `nil` if there are no arguments
      def last_argument
        arguments[-1]
      end

      # Checks whether this method was invoked with arguments.
      #
      # @return [Boolean] whether this method was invoked with arguments
      def arguments?
        !arguments.empty?
      end

      # Checks whether any argument of the method invocation is a splat
      # argument, i.e. `*splat`.
      #
      # @return [Boolean] whether the invoked method is a splat argument
      def splat_argument?
        arguments? && arguments.any?(&:splat_type?)
      end

      # Whether the last argument of the method invocation is a block pass,
      # i.e. `&block`.
      #
      # @return [Boolean] whether the invoked method is a block pass
      def block_argument?
        arguments? && last_argument.block_pass_type?
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
    end
  end
end
