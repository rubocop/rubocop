# frozen_string_literal: true

module RuboCop
  module Cop
    # Autocorrection logic for the closing brace of a literal either
    # on the same line as the last contained elements, or a new line.
    class MultilineLiteralBraceCorrector
      include MultilineLiteralBraceLayout
      include RangeHelp

      def self.correct(corrector, node, processed_source)
        new(corrector, node, processed_source).call
      end

      def initialize(corrector, node, processed_source)
        @corrector = corrector
        @node = node
        @processed_source = processed_source
      end

      def call
        if closing_brace_on_same_line?(node)
          correct_same_line_brace(corrector)
        else
          # When a comment immediately before the closing brace gets in the
          # way of an easy correction, the offense is reported but not auto-
          # corrected. The user must handle the delicate decision of where to
          # put the comment.
          return if new_line_needed_before_closing_brace?(node)
          return if nested_closing_bracket_moved_before_comment?
          return if nested_heredoc_argument_bracket_to_move?

          end_range = last_element_range_with_trailing_comma(node).end

          correct_next_line_brace(corrector, end_range)
          correct_code_after_heredoc_argument_brace(corrector, end_range)
        end
      end

      private

      attr_reader :corrector, :node, :processed_source

      def correct_same_line_brace(corrector)
        corrector.insert_before(node.loc.end, "\n")
      end

      def nested_closing_bracket_moved_before_comment?
        last_line = children(node).last.last_line

        node.each_descendant.any? { |nested| nested_closing_bracket_to_move?(nested, last_line) }
      end

      def nested_closing_bracket_to_move?(descendant, line)
        return false unless same_kind_as_node?(descendant)
        return false unless closing_bracket_on_own_line?(descendant, line)

        closing_bracket_moved_before_comment?(descendant)
      end

      def same_kind_as_node?(descendant)
        descendant.type == node.type || (descendant.call_type? && node.call_type?)
      end

      def closing_bracket_on_own_line?(descendant, line)
        return false unless descendant.loc?(:end) && descendant.loc.end.is?('}', ']', ')')

        closing_bracket = descendant.loc.end
        return false if closing_bracket.line != line

        closing_bracket.source_line[0...closing_bracket.column].strip.empty?
      end

      def closing_bracket_moved_before_comment?(literal)
        last_element = literal.call_type? ? literal.last_argument : literal.children.last
        return false if last_element.nil?
        return false if new_line_needed_before_closing_brace?(literal)

        comment_before_closing_brace?(literal, last_element)
      end

      def nested_heredoc_argument_bracket_to_move?
        last_line = children(node).last.last_line

        node.each_descendant(:call).any? do |nested|
          heredoc_first_argument?(nested) && closing_bracket_on_own_line?(nested, last_line) &&
            !new_line_needed_before_closing_brace?(nested)
        end
      end

      def correct_next_line_brace(corrector, end_range)
        corrector.remove(space_before_closing_brace(end_range))
        corrector.insert_before(end_range, content_if_comment_present(corrector, node))
      end

      def space_before_closing_brace(end_range)
        range = range_with_surrounding_space(node.loc.end, side: :left, continuations: true)
        return range if range.begin_pos >= end_range.end_pos

        range.with(begin_pos: end_range.end_pos)
      end

      def correct_code_after_heredoc_argument_brace(corrector, end_range)
        return unless heredoc_first_argument?(node)
        return if comment_before_closing_brace?(node, children(node).last)

        code_after_brace = code_after_closing_brace

        corrector.remove(code_after_brace)
        corrector.insert_after(end_range, code_after_brace.source)
      end

      def code_after_closing_brace
        range_between(node.loc.end.end_pos, range_by_whole_lines(node.loc.end).end_pos)
      end

      def content_if_comment_present(corrector, node)
        if comment_before_closing_brace?(node, children(node).last)
          select_content_to_be_inserted_after_last_element(corrector, node)
        else
          node.loc.end.source
        end
      end

      def comment_before_closing_brace?(literal, last_element)
        lines_before_closing_brace = last_element.last_line...literal.loc.end.line

        processed_source.each_comment_in_lines(lines_before_closing_brace).any?
      end

      def heredoc_first_argument?(call)
        return false unless call.respond_to?(:first_argument)
        return false unless (first_argument = call.first_argument)

        first_argument.any_str_type? && first_argument.heredoc?
      end

      def select_content_to_be_inserted_after_last_element(corrector, node)
        range = range_between(
          node.loc.end.begin_pos,
          range_by_whole_lines(node.source_range).end.end_pos
        )

        remove_trailing_content_of_comment(corrector, range)
        range.source
      end

      def remove_trailing_content_of_comment(corrector, range)
        corrector.remove(range)
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
          children(node).last.source_range,
          side: :right
        ).end.resize(1)

        range.source == ',' ? range : nil
      end
    end
  end
end
