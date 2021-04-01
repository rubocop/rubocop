# frozen_string_literal: true

module RuboCop
  module Cop
    # Help methods for working with nodes containing comments.
    module CommentsHelp
      include VisibilityHelp

      def source_range_with_comment(node)
        begin_pos = begin_pos_with_comment(node)
        end_pos = end_position_for(node)
        end_pos += 1 if node.def_type?

        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end

      private

      def end_position_for(node)
        end_line = buffer.line_for_position(node.loc.expression.end_pos)
        buffer.line_range(end_line).end_pos
      end

      def begin_pos_with_comment(node)
        annotation_line = node.first_line - 1
        first_comment = nil

        processed_source.comments_before_line(annotation_line)
                        .reverse_each do |comment|
          if comment.location.line == annotation_line
            first_comment = comment
            annotation_line -= 1
          end
        end

        start_line_position(first_comment || node)
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
