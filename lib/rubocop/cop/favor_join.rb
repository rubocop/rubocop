# encoding: utf-8

module Rubocop
  module Cop
    class FavorJoin < Cop
      ERROR_MESSAGE = 'Favor Array#join over Array#*.'

      def inspect(file, source, tokens, sexp)
        each(:binary, sexp) do |s|
          op1 = s[1]
          operator = s[2]
          op2 = s[3]

          # we care only about the * operator
          next unless matching?(operator, op1, op2)

          pos = all_positions(s[1]).first
          lineno = pos.lineno if pos

          add_offence(
            :convention,
            lineno,
            ERROR_MESSAGE
          ) if lineno
        end
      end

      private

      def matching?(operator, op1, op2)
        return false unless operator == :*

        op1[0] == :array and op2[0] == :string_literal
      end
    end
  end
end
