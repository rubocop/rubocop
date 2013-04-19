# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      ERROR_MESSAGE = 'Use alias_method instead of alias.'

      def inspect(file, source, tokens, sexp)
        each(:alias, sexp) do |s|
          if s[1][1][0] == :symbol
            # alias :full_name :name
            lineno = s[1][1][1][2].lineno
          else
            # alias full_name name
            lineno = s[1][1][2].lineno
          end

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
