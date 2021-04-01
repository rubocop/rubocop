# frozen_string_literal: true

module RuboCop
  module Cop
    # This auto-corrects parentheses
    class ParenthesesCorrector
      class << self
        def correct(corrector, node)
          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)
          return unless ternary_condition?(node) && next_char_is_question_mark?(node)

          corrector.insert_after(node.loc.end, ' ')
        end

        private

        def ternary_condition?(node)
          node.parent&.if_type? && node.parent&.ternary?
        end

        def next_char_is_question_mark?(node)
          node.loc.last_column == node.parent.loc.question.column
        end
      end
    end
  end
end
