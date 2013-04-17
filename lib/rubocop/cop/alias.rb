# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      ERROR_MESSAGE = 'Use alias_method instead of alias.'

      def inspect(file, source, tokens, sexp)
        each(:alias, sexp) do |s|
          lineno = s[1][1][1][2].lineno

          add_offence(
            :convention,
            lineno,
            ERROR_MESSAGE
          )
        end
      end
    end
  end
end
