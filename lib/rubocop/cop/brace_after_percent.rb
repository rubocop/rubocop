# encoding: utf-8

module Rubocop
  module Cop
    class BraceAfterPercent < Cop
      ERROR_MESSAGE = 'Prefer () as delimiters for all % literals.'
      LITERALS = {
        on_tstring_beg: ['%q', '%Q'],
        on_words_beg: '%W',
        on_qwords_beg: '%w',
        on_qsymbols_beg: '%i',
        on_symbols_beg: '%I',
        on_regexp_beg: '%r',
        on_symbeg: '%s',
        on_backtick: '%x'
      }

      def inspect(file, source, tokens, sexp)
        tokens.each_index do |ix|
          t = tokens[ix]
          literals = Array(LITERALS[t.type])
          literals.each do |literal|
            if literal && t.text.start_with?(literal) && t.text[2] != '('
              add_offence(:convention, t.pos.lineno,
                          ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
