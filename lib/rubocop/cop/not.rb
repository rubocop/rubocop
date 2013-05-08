# encoding: utf-8

module Rubocop
  module Cop
    class Not < Cop
      ERROR_MESSAGE = 'Use ! instead of not.'

      def inspect(file, source, tokens, sexp)
        each_keyword('not', tokens) do |t|
          add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
        end
      end
    end
  end
end
