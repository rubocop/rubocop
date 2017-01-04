# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `case` nodes.
    class CaseNode < Node
      include ConditionalNode

      def keyword
        'case'
      end

      def each_when
        return when_branches.to_enum unless block_given?

        when_branches.each do |condition|
          yield condition
        end

        self
      end

      def when_branches
        node_parts[1...-1]
      end

      def else_branch
        node_parts[-1]
      end

      def else?
        loc.else
      end

      def node_parts
        [*self]
      end
    end
  end
end
