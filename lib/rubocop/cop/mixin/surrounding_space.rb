# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking surrounding space.
    module SurroundingSpace
      def space_between?(t1, _t2)
        # Check if the range between the tokens starts with a space. It can
        # contain other characters, e.g. a unary plus, but it must start with
        # space.
        t1.pos.source_buffer.source.match(/\G\s/, t1.pos.end_pos)
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
    end
  end
end
