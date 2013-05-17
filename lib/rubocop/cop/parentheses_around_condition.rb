# encoding: utf-8

module Rubocop
  module Cop
    class ParenthesesAroundCondition < Cop
      ERROR_MESSAGE = "Don't use parentheses around the condition of an " +
        'if/unless/while/until, unless the condition contains an assignment.'

      def inspect(file, source, tokens, sexp)
        # TODO
      end
    end
  end
end
