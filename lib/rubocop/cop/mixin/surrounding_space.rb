# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking surrounding space.
    module SurroundingSpace
      def space_between?(t1, t2)
        between = Parser::Source::Range.new(t1.pos.source_buffer,
                                            t1.pos.end_pos,
                                            t2.pos.begin_pos).source

        # Check if the range between the tokens starts with a space. It can
        # contain other characters, e.g. a unary plus, but it must start with
        # space.
        between =~ /^\s/
      end

      def index_of_first_token(node)
        b = node.source_range.begin
        token_table[b.line][b.column]
      end

      def index_of_last_token(node)
        e = node.source_range.end
        (0...e.column).reverse_each do |c|
          ix = token_table[e.line][c]
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
