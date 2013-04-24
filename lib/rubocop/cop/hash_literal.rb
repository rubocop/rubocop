# encoding: utf-8

module Rubocop
  module Cop
    class HashLiteral < Cop
      ERROR_MESSAGE = 'Use hash literal {} instead of Hash.new.'

      def inspect(file, source, tokens, sexp)
        each(:method_add_arg, sexp) do |s|
          potential_class = s[1][1][1]

          if potential_class && potential_class[1] == 'Hash' &&
              s[1][3][1] == 'new' && s[2] == [:arg_paren, nil]
            add_offence(:convention,
                        potential_class[2].lineno,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
