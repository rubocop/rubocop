# frozen_string_literal: true

module RuboCop
  module Cop
    # Help methods for working with nodes containing comments.
    module CommentsHelp
      include VisibilityHelp

      def source_range_with_comment(node)
        begin_pos = begin_pos_with_comment(node)
        end_pos = end_position_for(node)

        Parser::Source::Range.new(buffer, begin_pos, end_pos)
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
    end
  end
end
