# frozen_string_literal: true

module RuboCop
  module Cop
    # This autocorrects parentheses
    class ParenthesesCorrector
      class << self
        include RangeHelp

        def correct(corrector, node)
          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)
          handle_orphaned_comma(corrector, node)

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

        def only_closing_paren_before_comma?(node)
          source_buffer = node.source_range.source_buffer
          line_range = source_buffer.line_range(node.loc.end.line)

          line_range.source.start_with?(/\s*\)\s*,/)
        end

        # If removing parentheses leaves a comma on its own line, remove all the whitespace
        # preceding it to prevent a syntax error.
        def handle_orphaned_comma(corrector, node)
          return unless only_closing_paren_before_comma?(node)

          range = range_with_surrounding_space(
            range: node.loc.end,
            buffer: node.source_range.source_buffer,
            side: :left,
            newlines: true,
            whitespace: true,
            continuations: true
          )

          corrector.remove(range)
        end
      end
    end
  end
end
