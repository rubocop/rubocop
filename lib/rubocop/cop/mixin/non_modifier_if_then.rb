# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking if an `if` node is in nonmodifier form with implicit `then`.
    module NonModifierIfThen
      NON_MODIFIER_THEN = /then\s*(#.*)?$/.freeze

      def non_modifier_if_then?(node, same_line: false)
        return false unless node.if_type?

        if same_line
          same_line?(node.children[1], node)
        else
          NON_MODIFIER_THEN.match?(node.loc.begin&.source_line)
        end
      end
    end
  end
end
