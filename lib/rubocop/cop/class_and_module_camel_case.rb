# encoding: utf-8

module Rubocop
  module Cop
    class ClassAndModuleCamelCase < Cop
      ERROR_MESSAGE = 'Use CamelCase for classes and modules.'

      def inspect(file, source, tokens, sexp)
        [:class, :module].each do |keyword|
          each(keyword, sexp) do |s|
            if s[1][0] == :const_ref && s[1][1][0] == :@const &&
                s[1][1][1] =~ /_/
              add_offence(:convention, s[1][1][2].lineno, ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
