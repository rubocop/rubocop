# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `while` nodes.
    class WhileNode < Node
      include ConditionalNode
      include ModifierNode

      def keyword
        'while'
      end

      def inverse_keyword
        'until'
      end

      def do?
        loc.begin && loc.begin.is?('do')
      end

      def node_parts
        [*self]
      end
    end
  end
end
