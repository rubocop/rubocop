# encoding: utf-8

module Rubocop
  module Cop
    # This module contains a utility methods for ranges.
    module RangeUtil
      def source_range(preceding_lines, begin_column, column_count)
        newline_length = 1
        begin_pos = preceding_lines.reduce(0) do |a, e|
          a + e.length + newline_length
        end + begin_column
        new_range(begin_pos, begin_pos + column_count)
      end

      def range_with_surrounding_space(range, side = :both)
        src = processed_source.buffer.source
        go_left = side == :left || side == :both
        go_right = side == :right || side == :both
        begin_pos = range.begin_pos
        begin_pos -= 1 while go_left && src[begin_pos - 1] =~ /[ \t]/
        end_pos = range.end_pos
        end_pos += 1 while go_right && src[end_pos] =~ /[ \t]/
        end_pos += 1 if go_right && src[end_pos] == "\n"
        new_range(begin_pos, end_pos)
      end

      def new_range(begin_pos, end_pos)
        Parser::Source::Range.new(processed_source.buffer, begin_pos, end_pos)
      end
    end
  end
end
