# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      ERROR_MESSAGE = 'Use alias_method instead of alias.'

      def inspect(file, source, tokens, sexp)
        each_keyword('alias', tokens) do |t|
          add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
        end
      end
    end
  end
end
