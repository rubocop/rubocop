# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `super`- and `zsuper` nodes. This will be used in
    # place of a plain node when the builder constructs the AST, making its
    # methods available to all `super`- and `zsuper` nodes within RuboCop.
    class SuperNode < Node
      include ParameterizedNode
      include MethodIdentifierPredicates

      # The method name of this `super` node. Always `:super`.
      #
      # @return [Symbol] the method name of `super`
      def method_name
        :super
      end

      # The receiver of this `super` node. Always `nil`.
      #
      # @return [nil] the receiver of `super`
      def receiver
        nil
      end

      # An array containing the arguments of the super invocation.
      #
      # @return [Array<Node>] the arguments of the super invocation
      def arguments
        node_parts
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
      # @return [Array] the different parts of the `block` node
      def node_parts
        to_a
      end
    end
  end
end
