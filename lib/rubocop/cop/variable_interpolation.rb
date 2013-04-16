# encoding: utf-8

module Rubocop
  module Cop
    class VariableInterpolation < Cop
      def inspect(file, source, tokens, sexp)
        each(:string_dvar, sexp) do |s|
          var = s[1][1][1]
          lineno = s[1][1][2].lineno

          add_offence(
            :convention,
            lineno,
            "Replace interpolated var #{var} with expression \#{#{var}}."
          )
        end
      end
    end
  end
end
