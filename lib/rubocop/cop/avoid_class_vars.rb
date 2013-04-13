# encoding: utf-8

module Rubocop
  module Cop
    class AvoidClassVars < Cop
      def inspect(file, source, tokens, sexp)
        each(:@cvar, sexp) do |s|
          class_var = s[1]
          lineno = s[2].lineno

          add_offence(
            :convention,
            lineno,
            "Replace class var #{class_var} with a class instance var."
          )
        end
      end
    end
  end
end
