# encoding: utf-8

module Rubocop
  module Cop
    module FavorModifier
      def check(kind, tokens, sexp)
        token_positions = tokens.map(&:pos)
        token_texts = tokens.map(&:text)
        each(kind, sexp) do |s|
          # If it contains an else, it can't be written as a modifier.
          next if s[3] && s[3][0] == :else

          sexp_positions = all_positions(s)
          ix = token_positions.index(sexp_positions.first)
          if_ix = token_texts[0..ix].rindex(kind.to_s) # index of if/unless/...
          ix = token_positions.index(sexp_positions.last)
          end_ix = ix + token_texts[ix..-1].index('end')

          # If there's a comment anywhere between
          # if/unless/while/until and end, we don't report. It's
          # possible that the comment will be less clear if put above
          # a one liner rather than inside.
          next if tokens[if_ix...end_ix].map(&:type).include?(:on_comment)

          if token_positions[end_ix].lineno - token_positions[if_ix].lineno > 2
            next # not a single-line body
          end
          # The start ix is the index of the leftmost token on the
          # line of the if/unless, i.e. the index of if/unless itself,
          # or of the indentation space.
          start_ix = if_ix.downto(0).find do |block_ix|
            block_ix == 0 || tokens[block_ix - 1].text =~ /\n/
          end
          # The stop index is the index of the token just before
          # 'end', not counting whitespace tokens.
          stop_ix = (end_ix - 1).downto(0).find do |block_ix|
            tokens[block_ix].text !~ /\s/
          end
          if length(tokens, start_ix, stop_ix) <= LineLength.max
            add_offence(:convention, token_positions[if_ix].lineno,
                        error_message)
          end
        end
      end

      def length(tokens, start_ix, stop_ix)
        (start_ix..stop_ix).reduce(0) do |acc, ix|
          acc + if ix > start_ix && tokens[ix - 1].text =~ /\n/
                  0
                else
                  tokens[ix].text.length
                end
        end
      end
    end

    class IfUnlessModifier < Cop
      include FavorModifier

      def error_message
        'Favor modifier if/unless usage when you have a single-line body. ' +
          'Another good alternative is the usage of control flow and/or.'
      end

      def inspect(file, source, tokens, sexp)
        [:if, :unless].each { |kind| check(kind, tokens, sexp) }
      end
    end

    class WhileUntilModifier < Cop
      include FavorModifier

      def error_message
        'Favor modifier while/until usage when you have a single-line body.'
      end

      def inspect(file, source, tokens, sexp)
        [:while, :until].each { |kind| check(kind, tokens, sexp) }
      end
    end
  end
end
