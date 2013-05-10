# encoding: utf-8

module Rubocop
  module Cop
    class VariableInterpolation < Cop
      def inspect(file, source, tokens, sexp)
        each(:string_dvar, sexp) do |s|
          interpolation = s[1][0] == :@backref ? s[1] : s[1][1]
          var = interpolation[1]
          lineno = interpolation[2].lineno

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
