# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking if nodes.
    module DefNode
      extend NodePattern::Macros

      NON_PUBLIC_MODIFIERS = %w[private protected].freeze

      def non_public?(node)
        non_public_modifier?(node.parent) ||
          preceding_non_public_modifier?(node)
      end

      def preceding_non_public_modifier?(node)
        stripped_source_upto(node.loc.line).any? do |line|
          NON_PUBLIC_MODIFIERS.include?(line)
        end
      end

      def_node_matcher :non_public_modifier?, <<-PATTERN
        (send nil {:private :protected} ({def defs} ...))
      PATTERN
    end
  end
end
