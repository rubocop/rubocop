# encoding: utf-8

module Rubocop
  module Cop
    class MethodAndVariableSnakeCase < Cop
      ERROR_MESSAGE = 'Use snake_case for methods and variables.'
      CAMEL_CASE = /^@?[A-Za-z]*[A-Z][a-z][A-Za-z]*$/

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) { |s| check(s[1]) }

        each(:assign, sexp) do |s|
          case s[1][0]
          when :var_field
            check(s[1][1])
          when :field
            if s[1][1][0] == :var_ref && s[1][1][1][0..1] == [:@kw, 'self']
              check(s[1][3])
            end
          end
        end
      end

      def check(sexp)
        if [:@ivar, :@ident].include?(sexp[0]) && sexp[1] =~ CAMEL_CASE
          add_offence(:convention, sexp[2].lineno, ERROR_MESSAGE)
        end
      end
    end
  end
end
