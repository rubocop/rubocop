# encoding: utf-8

module Rubocop
  module Cop
    class ClassMethods < Cop
      ERROR_MESSAGE = 'Prefer self over class/module for class/module methods.'

      def inspect(file, source, tokens, sexp)
        each(:class, sexp) { |d| process_defs(d) }
        each(:module, sexp) { |d| process_defs(d) }
      end

      private

      def process_defs(sexp)
        each(:defs, sexp) do |s|
          if s[1][0] == :var_ref && s[1][1][0] == :@const
            add_offence(:convention,
                        s[1][1][2].lineno,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
