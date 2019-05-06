# frozen_string_literal: true

module RuboCop
  module Cop
    # Autocorrection logic for the closing brace of a literal either
    # on the same line as the last contained elements, or a new line.
    class MultilineLiteralBraceCorrector
      include MultilineLiteralBraceLayout
      include RangeHelp

      def initialize(node, processed_source)
        @node = node
        @processed_source = processed_source
      end

      def call(corrector)
        if closing_brace_on_same_line?(node)
          correct_same_line_brace(corrector)
        else
          # When a comment immediately before the closing brace gets in the
          # way of an easy correction, the offense is reported but not auto-
          # corrected. The user must handle the delicate decision of where to
          # put the comment.
          return if new_line_needed_before_closing_brace?(node)

          correct_next_line_brace(corrector)
        end
      end

      private

      attr_reader :node, :processed_source

      def correct_same_line_brace(corrector)
        corrector.insert_before(node.loc.end, "\n")
      end

      def correct_next_line_brace(corrector)
        corrector.remove(
          range_with_surrounding_space(range: node.loc.end, side: :left)
        )

        corrector.insert_after(
          last_element_range_with_trailing_comma(node),
          node.loc.end.source
        )
      end

      def last_element_range_with_trailing_comma(node)
        trailing_comma_range = last_element_trailing_comma_range(node)
        if trailing_comma_range
          children(node).last.source_range.join(trailing_comma_range)
        else
          children(node).last.source_range
        end
      end

      def last_element_trailing_comma_range(node)
        range = range_with_surrounding_space(
          range: children(node).last.source_range,
          side: :right
        ).end.resize(1)

        range.source == ',' ? range : nil
      end
    end
  end
end
