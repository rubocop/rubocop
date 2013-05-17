# encoding: utf-8

module Rubocop
  module Cop
    class AsciiComments < Cop
      ERROR_MESSAGE = 'Use only ascii symbols in comments.'

      def inspect(file, source, sexp)
        # TODO implemented when Parser starts tracking comments
      end
    end
  end
end
