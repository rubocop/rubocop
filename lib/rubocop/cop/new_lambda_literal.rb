# encoding: utf-8

module Rubocop
  module Cop
    class NewLambdaLiteral < Cop
      ERROR_MESSAGE = 'The new lambda literal syntax is preferred in Ruby 1.9.'

      def inspect(file, source, tokens, sexp)
        each(:fcall, sexp) do |s|
          if s[1][0..1] == [:@ident, 'lambda']
            add_offence(:convention, s[1][-1].lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
