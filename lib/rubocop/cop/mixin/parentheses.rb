# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling parentheses.
    module Parentheses
      def parens_required?(node)
        range  = node.source_range
        source = range.source_buffer.source
        source[range.begin_pos - 1] =~ /[a-z]/ ||
          source[range.end_pos] =~ /[a-z]/
      end

      def autocorrect(node)
        lambda do |corrector|
          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)

          if ternary_condition?(node) && next_char_is_question_mark?(node)
            corrector.insert_after(node.loc.end, ' ')
          end
        end
      end

      def ternary_condition?(node)
        node.parent && node.parent.if_type? && node.parent.ternary?
      end

      def next_char_is_question_mark?(node)
        node.loc.last_column == node.parent.loc.question.column
      end
    end
  end
end
