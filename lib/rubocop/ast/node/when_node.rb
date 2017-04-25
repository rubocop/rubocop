# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `when` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `when` nodes within RuboCop.
    class WhenNode < Node
      # Returns an array of all the conditions in the `when` branch.
      #
      # @return [Array<Node>] an array of condition nodes
      def conditions
        node_parts[0...-1]
      end

      # Calls the given block for each condition node in the `when` branch.
      # If no block is given, an `Enumerator` is returned.
      #
      # @return [self] if a block is given
      # @return [Enumerator] if no block is given
      def each_condition
        return conditions.to_enum(__method__) unless block_given?

        conditions.each do |condition|
          yield condition
        end

        self
      end

      # Returns the index of the `when` branch within the `case` statement.
      #
      # @return [Integer] the index of the `when` branch
      def branch_index
        parent.when_branches.index(self)
      end

      # Checks whether the `when` node has a `then` keyword.
      #
      # @return [Boolean] whether the `when` node has a `then` keyword
      def then?
        loc.begin && loc.begin.is?('then')
      end

      # Returns the body of the `when` node.
      #
      # @return [Node, nil] the body of the `when` node
      def body
        node_parts[-1]
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
