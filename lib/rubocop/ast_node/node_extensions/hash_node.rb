# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # A node extension for `hash` nodes.
    module HashNode
      def pairs
        each_pair.to_a
      end

      def each_pair
        return each_child_node(:pair).to_enum unless block_given?

        each_child_node(:pair) do |pair|
          yield(*pair)
        end

        self
      end

      def keys
        each_pair.map(&:child_nodes).map(&:first)
      end

      def values
        each_pair.map(&:child_nodes).map(&:last)
      end

      def pairs_on_same_line?
        pairs.each_cons(2).any? do |first, second|
          first.loc.last_line == second.loc.line
        end
      end

      def braces?
        loc.end
      end
    end
  end
end
