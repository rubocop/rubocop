# encoding: utf-8

module Rubocop
  module Cop
    class RescueModifier < Cop
      ERROR_MESSAGE = 'Avoid using rescue in its modifier form.'

      def inspect(file, source, tokens, sexp)
        each(:rescue_mod, sexp) do |s|
          ident = find_first(:@ident, s)
          lineno = ident ? ident[2].lineno : nil

          add_offence(:convention,
                      lineno,
                      ERROR_MESSAGE) if lineno
        end
      end
    end
  end
end
