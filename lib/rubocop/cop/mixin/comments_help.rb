# frozen_string_literal: true

module RuboCop
  module Cop
    # Help methods for working with nodes containing comments.
    module CommentsHelp
      def source_range_with_comment(node)
        begin_pos = begin_pos_with_comment(node)
        end_pos = end_position_for(node)

        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end

      def contains_comments?(node)
        comments_in_range(node).any?
      end

      def comments_in_range(node)
        start_line = node.source_range.line
        end_line = find_end_line(node)

        processed_source.each_comment_in_lines(start_line...end_line)
      end

      private

      def end_position_for(node)
        end_line = buffer.line_for_position(node.loc.expression.end_pos)
        buffer.line_range(end_line).end_pos
      end

      def begin_pos_with_comment(node)
        first_comment = processed_source.ast_with_comments[node].first

        if first_comment && (first_comment.loc.line < node.loc.line)
          start_line_position(first_comment)
        else
          start_line_position(node)
        end
      end

      def start_line_position(node)
        buffer.line_range(node.loc.line).begin_pos - 1
      end

      def buffer
        processed_source.buffer
      end

      # Returns the end line of a node, which might be a comment and not part of the AST
      # End line is considered either the line at which another node starts, or
      # the line at which the parent node ends.
      # rubocop:disable Metrics/AbcSize
      def find_end_line(node)
        if node.if_type? && node.loc.else
          node.loc.else.line
        elsif (next_sibling = node.right_sibling)
          next_sibling.loc.line
        elsif (parent = node.parent)
          parent.loc.end ? parent.loc.end.line : parent.loc.line
        else
          node.loc.end.line
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
