# frozen_string_literal: true

module RuboCop
  module Cop
    # This module extends ProcessedSource with helper functionality.
    module ProcessedSourceLogic
      def each_comment
        comments.each { |comment| yield comment }
      end

      def find_comment
        comments.find { |comment| yield comment }
      end

      def each_token
        tokens.each { |token| yield token }
      end

      def find_token
        tokens.find { |token| yield token }
      end

      def file_path
        buffer.name
      end

      def blank?
        ast.nil?
      end

      def aligned_comments?(token)
        ix = comments.index do |comment|
          comment.loc.expression.begin_pos == token.begin_pos
        end
        aligned_with_previous_comment?(ix) || aligned_with_next_comment?(ix)
      end

      def commented?(source)
        comment_lines.include?(source.line)
      end

      def comment_on_line?(line)
        comments.any? { |c| c.loc.line == line }
      end

      def comments_before_line(line)
        comments.select { |c| c.location.line <= line }
      end

      def start_with?(string)
        return false if self[0].nil?
        self[0].start_with?(string)
      end

      def preceding_line(token)
        lines[token.line - 2]
      end

      def following_line(token)
        lines[token.line]
      end

      def stripped_upto(line)
        self[0..line].map(&:strip)
      end

      def previous_and_current_lines_empty?(line)
        self[line - 2].empty? && self[line - 1].empty?
      end

      def empty_brackets?(left_bracket, right_bracket)
        tokens.index(left_bracket) ==
          tokens.index(right_bracket) - 1
      end

      private

      def comment_lines
        @comment_lines ||= comments.map { |c| c.location.line }
      end

      def aligned_with_previous_comment?(index)
        index > 0 && comment_column(index - 1) == comment_column(index)
      end

      def aligned_with_next_comment?(index)
        index < comments.length - 1 &&
          comment_column(index + 1) == comment_column(index)
      end

      def comment_column(index)
        comments[index].loc.column
      end
    end
  end
end
