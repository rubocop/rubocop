# encoding: utf-8

module Rubocop
  module Cop
    class AsciiComments < Cop
      MSG = 'Use only ascii symbols in comments.'

      def inspect(file, source, tokens, sexp)
        # TODO implemented when Parser starts tracking comments
      end
    end
  end
end
