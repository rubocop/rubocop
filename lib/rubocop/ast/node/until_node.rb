# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `until` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `until` nodes within RuboCop.
    class UntilNode < Node
      include ConditionalNode
      include ModifierNode

      # Returns the keyword of the `until` statement as a string.
      #
      # @return [String] the keyword of the `until` statement
      def keyword
        'until'
      end

      # Returns the inverse keyword of the `until` node as a string.
      # Returns `while` for `until` nodes and vice versa.
      #
      # @return [String] the inverse keyword of the `until` statement
      def inverse_keyword
        'while'
      end

      # Checks whether the `until` node has a `do` keyword.
      #
      # @return [Boolean] whether the `until` node has a `do` keyword
      def do?
        loc.begin && loc.begin.is?('do')
      end

      # Custom destructuring method. This can be used to normalize
      # destructuring for different variations of the node.
      #
      # @return [Array<Node>] the different parts of the `until` statement
      def node_parts
        to_a
      end
    end
  end
end
