# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `sym` nodes. This will be used in  place of a
    # plain node when the builder constructs the AST, making its methods
    # available to all `sym` nodes within RuboCop.
    class SymbolNode < Node
      include BasicLiteralNode

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array] the different parts of the `sym` node
      def node_parts
        to_a
      end
    end
  end
end
