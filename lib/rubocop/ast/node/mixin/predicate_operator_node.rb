# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that are predicates:
    # `or`, `and` ...
    module PredicateOperatorNode
      LOGICAL_AND  = '&&'.freeze
      SEMANTIC_AND = 'and'.freeze
      LOGICAL_OR   = '||'.freeze
      SEMANTIC_OR  = 'or'.freeze

      # Returns the operator as a string.
      #
      # @return [String] the operator
      def operator
        loc.operator.source
      end

      # Checks whether this is a logical operator.
      #
      # @return [Boolean] whether this is a logical operator
      def logical_operator?
        operator == LOGICAL_AND || operator == LOGICAL_OR
      end

      # Checks whether this is a semantic operator.
      #
      # @return [Boolean] whether this is a semantic operator
      def semantic_operator?
        operator == SEMANTIC_AND || operator == SEMANTIC_OR
      end
    end
  end
end
