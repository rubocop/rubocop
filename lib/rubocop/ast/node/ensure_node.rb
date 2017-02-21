# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `ensure` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `ensure` nodes within RuboCop.
    class EnsureNode < Node
      # Returns the body of the `ensure` clause.
      #
      # @return [Node, nil] The body of the `ensure`.
      def body
        node_parts[1]
      end

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array<Node>] the different parts of the `ensure` statement
      def node_parts
        [*self]
      end
    end
  end
end
