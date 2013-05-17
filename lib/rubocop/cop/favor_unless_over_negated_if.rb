# encoding: utf-8

module Rubocop
  module Cop
    module FavorOtherKeywordOverNegation
    end

    class FavorUnlessOverNegatedIf < Cop
      include FavorOtherKeywordOverNegation

      def error_message
        'Favor unless (or control flow or) over if for negative conditions.'
      end

      def inspect(file, source, sexp)
        #TODO
      end
    end

    class FavorUntilOverNegatedWhile < Cop
      include FavorOtherKeywordOverNegation

      def error_message
        'Favor until over while for negative conditions.'
      end

      def inspect(file, source, sexp)
        #TODO
      end
    end
  end
end
