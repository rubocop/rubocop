# encoding: utf-8

module Rubocop
  module Cop
    class ParameterLists < Cop
      ERROR_MESSAGE = 'Avoid parameter lists longer than four parameters.'

      def inspect(file, source, tokens, sexp)
        each(:params, sexp) do |params|
          if params[1] && params[1].size > 4
            add_offence(:convention, params[1][0][-1].lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
