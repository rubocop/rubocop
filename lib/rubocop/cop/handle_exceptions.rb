# encoding: utf-8

module Rubocop
  module Cop
    class HandleExceptions < Cop
      ERROR_MESSAGE = 'Do not suppress exceptions.'

      def inspect(file, source, tokens, sexp)
        each(:begin, sexp) do |s|
          each(:rescue, s) do |rs|
            if rs[3] == [[:void_stmt]]
              add_offence(:warning,
                          all_positions(s)[-1].lineno + 1,
                          ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
