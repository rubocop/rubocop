# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # Common functionality for nodes that can be used as modifiers:
    # `if`, `while`, `until`
    module ModifierNode
      def modifier_form?
        loc.end.nil?
      end
    end
  end
end
