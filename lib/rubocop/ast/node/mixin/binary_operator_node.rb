# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that are binary operations:
    # `or`, `and` ...
    module BinaryOperatorNode
      # Returns the left hand side node of the binary operation.
      #
      # @return [Node] the left hand side of the binary operation
      def lhs
        node_parts[0]
      end

      # Returns the right hand side node of the binary operation.
      #
      # @return [Node] the right hand side of the binary operation
      def rhs
        node_parts[1]
      end
    end
  end
end
