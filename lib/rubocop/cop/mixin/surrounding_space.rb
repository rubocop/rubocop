# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking surrounding space.
    module SurroundingSpace
      def space_after?(token)
        # Checks if there is whitespace after token
        token.pos.source_buffer.source.match(/\G\s/, token.pos.end_pos)
      end

      def space_before?(token)
        # Checks if there is whitespace before token
        token.pos.source_buffer.source.match(/\G\s/, token.pos.begin_pos - 1)
      end

      def side_space_range(range:, side:)
        buffer = @processed_source.buffer
        src = buffer.source

        begin_pos = range.begin_pos
        end_pos = range.end_pos
        if side == :left
          begin_pos = reposition(src, begin_pos, -1)
          end_pos -= 1
        end
        if side == :right
          begin_pos += 1
          end_pos = reposition(src, end_pos, 1)
        end
        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end

      def index_of_first_token(node)
        range = node.source_range
        token_table[range.line][range.column]
      end

      def index_of_last_token(node)
        range = node.source_range
        table_row = token_table[range.last_line]
        (0...range.last_column).reverse_each do |c|
          ix = table_row[c]
          return ix if ix
        end
      end

      def token_table
        @token_table ||= begin
          table = {}
          @processed_source.tokens.each_with_index do |t, ix|
            table[t.pos.line] ||= {}
            table[t.pos.line][t.pos.column] = ix
          end
          table
        end
      end

      private

      def reposition(src, pos, step)
        offset = step == -1 ? -1 : 0
        pos += step while src[pos + offset] =~ /[ \t]/
        pos < 0 ? 0 : pos
      end
    end
  end
end
