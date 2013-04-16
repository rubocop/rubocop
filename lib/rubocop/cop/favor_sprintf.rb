# encoding: utf-8

module Rubocop
  module Cop
    class FavorSprintf < Cop
      ERROR_MESSAGE = 'Favor sprintf over String#%.'

      def inspect(file, source, tokens, sexp)
        each(:binary, sexp) do |s|
          op1 = s[1]
          operator = s[2]
          op2 = s[3]

          # we care only about the % operator
          next unless matching?(operator, op1, op2)

          # FIXME implement reliable lineno extraction
          if op1[0] == :string_literal
            lineno_struct = s[1][1][1][2]
            lineno = lineno_struct.lineno if lineno_struct.respond_to?(:lineno)
          else
            lineno_struct = s[1][1][2]
            lineno = lineno_struct.lineno if lineno_struct.respond_to?(:lineno)
          end

          add_offence(
            :convention,
            lineno,
            ERROR_MESSAGE
          ) if lineno
        end
      end

      private

      def matching?(operator, op1, op2)
        return false unless operator == :%

        op1[0] == :string_literal or op2[0] == :array
      end
    end
  end
end
