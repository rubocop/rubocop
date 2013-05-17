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

      def inspect(file, source, sexp)
        # TODO
      end
    end
  end
end
