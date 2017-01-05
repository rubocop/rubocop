# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `hash` nodes. This will be used in place of a plain
    # node when the builder constructs the AST, making its methods available
    # to all `hash` nodes within RuboCop.
    class HashNode < Node
      # Returns an array of all the key value pairs in the `hash` literal.
      #
      # @return [Array<PairNode>] an array of `pair` nodes
      def pairs
        each_pair.to_a
      end

      # Calls the given block for each `pair` node in the `hash` literal.
      # If no block is given, an `Enumerator` is returned.
      #
      # @return [self] if a block is given
      # @return [Enumerator] if no block is given
      def each_pair
        return each_child_node(:pair).to_enum unless block_given?

        each_child_node(:pair) do |pair|
          yield(*pair)
        end

        self
      end

      # Returns an array of all the keys in the `hash` literal.
      #
      # @return [Node] an array of keys in the `hash` literal
      def keys
        each_pair.map(&:child_nodes).map(&:first)
      end

      # Returns an array of all the values in the `hash` literal.
      #
      # @return [Node] an array of values in the `hash` literal
      def values
        each_pair.map(&:child_nodes).map(&:last)
      end

      # Checks whether any of the key value pairs in the `hash` literal are on
      # the same line.
      #
      # @return [Boolean] whether any `pair` nodes are on the same line
      def pairs_on_same_line?
        pairs.each_cons(2).any? do |first, second|
          first.loc.last_line == second.loc.line
        end
      end

      # Checks whether the `hash` literal is delimited by curly braces.
      #
      # @return [Boolean] whether the `hash` literal is enclosed in braces
      def braces?
        loc.end
      end
    end
  end
end
