# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for checking surrounding space.
    module SurroundingSpace
      def space_between?(t1, t2)
        char_preceding_2nd_token =
          @processed_source[t2.pos.line - 1][t2.pos.column - 1]
        if char_preceding_2nd_token == '+' && t1.type != :tPLUS
          # Special case. A unary plus is not present in the tokens.
          char_preceding_2nd_token =
            @processed_source[t2.pos.line - 1][t2.pos.column - 2]
        end
        t2.pos.line > t1.pos.line || char_preceding_2nd_token =~ /[ \t]/
      end

      def index_of_first_token(node)
        b = node.loc.expression.begin
        token_table[[b.line, b.column]]
      end

      def index_of_last_token(node)
        e = node.loc.expression.end
        (0...e.column).to_a.reverse.find do |c|
          ix = token_table[[e.line, c]]
          return ix if ix
        end
      end

      def token_table
        @token_table ||= begin
          table = {}
          @processed_source.tokens.each_with_index do |t, ix|
            table[[t.pos.line, t.pos.column]] = ix
          end
          table
        end
      end
    end
  end
end
