# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `resbody` nodes. This will be used in place of a
    # plain node when the builder constructs the AST, making its methods
    # available to all `resbody` nodes within RuboCop.
    class ResbodyNode < Node
      # Returns the body of the `rescue` clause.
      #
      # @return [Node, nil] The body of the `resbody`.
      def body
        node_parts[2]
      end

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array<Node>] the different parts of the `resbody` statement
      def node_parts
        to_a
      end
    end
  end
end
