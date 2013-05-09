# encoding: utf-8

module Rubocop
  module Cop
    class AvoidFor < Cop
      ERROR_MESSAGE = 'Prefer *each* over *for*.'

      def inspect(file, source, tokens, sexp)
        each_keyword('for', tokens) do |t|
          add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
        end
      end
    end
  end
end
