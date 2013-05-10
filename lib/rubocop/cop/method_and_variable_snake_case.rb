# encoding: utf-8

module Rubocop
  module Cop
    class MethodAndVariableSnakeCase < Cop
      ERROR_MESSAGE = 'Use snake_case for methods and variables.'
      SNAKE_CASE = /^@?[\da-z_]+[!?=]?$/
      CONSTANT = /^[A-Z]/

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) { |s| check(*s[1]) }

        each(:assign, sexp) do |s|
          case s[1][0]
          when :var_field
            check(*s[1][1]) unless s[1][1][1] =~ CONSTANT
          when :field
            if s[1][1][0] == :var_ref && s[1][1][1][0..1] == [:@kw, 'self']
              check(*s[1][3])
            end
          end
        end
      end

      def check(type, name, pos)
        if [:@ivar, :@ident, :@const].include?(type) && name !~ SNAKE_CASE
          add_offence(:convention, pos.lineno, ERROR_MESSAGE)
        end
      end
    end
  end
end
