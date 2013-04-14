# encoding: utf-8

module Rubocop
  module Cop
    class SymbolSnakeCase < Cop
      ERROR_MESSAGE = 'Use snake_case for symbols.'
      SNAKE_CASE = /^@?[\da-z_]+[!?=]?$/

      def inspect(file, source, tokens, sexp)
        each(:symbol_literal, sexp) do |s|
          symbol_ident = s[1][1][1]

          # handle a couple of special cases
          next if ['!', '[]', '**'].include?(symbol_ident)

          unless symbol_ident =~ SNAKE_CASE
            line_no = s[1][1][2].lineno
            add_offence(:convention,
                        line_no,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
