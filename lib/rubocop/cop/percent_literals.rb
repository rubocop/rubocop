# encoding: utf-8

module Rubocop
  module Cop
    class PercentLiterals < Cop
      ERROR_MESSAGE = 'The use of %s is discouraged.'
      BAD_LITERALS = {
        on_tstring_beg: '%q',
        on_symbeg: '%s',
        on_backtick: '%x'
      }

      def inspect(file, source, tokens, sexp)
        tokens.each_index do |ix|
          t = tokens[ix]
          bad_token = BAD_LITERALS[t.type]
          if bad_token && t.text.downcase.start_with?(bad_token)
            add_offence(:convention, t.pos.lineno,
                        sprintf(ERROR_MESSAGE, t.text[0, 2]))
          end
        end
      end
    end
  end
end
