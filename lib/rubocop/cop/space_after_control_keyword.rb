# encoding: utf-8

module Rubocop
  module Cop
    class SpaceAfterControlKeyword < Cop
      ERROR_MESSAGE = 'Use space after control keywords.'

      KEYWORDS = %w(if elsif case when while until unless)

      def inspect(file, source, tokens, sexp)
        tokens.each_with_index do |t, ix|
          symbol = symbeg?(tokens, ix - 1)
          if !symbol && t.type == :on_kw && KEYWORDS.include?(t.text)
            add_offence(:convention,
                        t.pos.lineno,
                        ERROR_MESSAGE) unless next_token_sp?(tokens, ix + 1)
          end
        end
      end

      def next_token_sp?(tokens, index)
        tokens[index] && tokens[index].type == :on_sp
      end

      def symbeg?(tokens, index)
        if index > 0 && tokens[index].type == :on_symbeg
          true
        else
          false
        end
      end
    end
  end
end
