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
          return if code_after_closing_brace_left_behind_heredoc?

          end_range = last_element_range_with_trailing_comma(node).end

          correct_next_line_brace(corrector, end_range)
          correct_method_chain_after_heredoc(corrector, end_range)
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

      def code_after_closing_brace_left_behind_heredoc?
        return false unless moved_brace_skips_heredoc_body?

        chained_method = method_chain_after_closing_brace
        return code_after?(node.loc.end) unless chained_method

        code_before?(chained_method) || code_after?(chained_method)
      end

      def code_before?(chained_method)
        !range_between(node.loc.end.end_pos, chained_method.begin_pos).source.strip.empty?
      end

      def code_after?(range)
        !range_by_whole_lines(range).with(begin_pos: range.end_pos).source.strip.empty?
      end

      def moved_brace_skips_heredoc_body?
        !comment_before_closing_brace?(node, children(node).last) &&
          heredoc_before_closing_brace?(node)
      end

      def method_chain_after_closing_brace
        return unless (dot = chained_method_dot(node))

        chain = node.parent
        chain = chain.parent while chained_method_dot(chain)&.line == dot.line
        range_between(dot.begin_pos, chain.source_range.end_pos) if chain.last_line == dot.line
      end

      def chained_method_dot(receiver)
        parent = receiver.parent
        parent.loc.dot if parent&.call_type? && parent.receiver.equal?(receiver)
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

      def correct_method_chain_after_heredoc(corrector, end_range)
        return unless moved_brace_skips_heredoc_body?
        return unless (chained_method = method_chain_after_closing_brace)

        corrector.remove(chained_method)
        corrector.insert_after(end_range, chained_method.source)
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
