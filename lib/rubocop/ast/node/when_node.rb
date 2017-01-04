# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `when` nodes.
    class WhenNode < Node
      def conditions
        node_parts[0...-1]
      end

      def each_condition
        return conditions.to_enum unless block_given?

        conditions.each do |condition|
          yield condition
        end

        self
      end

      def index
        parent.when_branches.index(self)
      end

      def then?
        loc.begin && loc.begin.is?('then')
      end

      def body
        node_parts[-1]
      end

      def node_parts
        [*self]
      end
    end
  end
end
