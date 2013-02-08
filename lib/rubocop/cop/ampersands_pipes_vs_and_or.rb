# encoding: utf-8

module Rubocop
  module Cop
    class AmpersandsPipesVsAndOr < Cop
      ERROR_MESSAGE =
        'Use &&/|| for boolean expressions, and/or for control flow.'

      def inspect(file, source, tokens, sexp)
        [:if, :unless, :while, :until].each { |keyword| check(keyword, sexp) }
      end

      def check(keyword, sexp)
        each(keyword, sexp) do |sub_sexp|
          condition = sub_sexp[1]
          if condition[0] == :binary && [:and, :or].include?(condition[2])
            add_offence(:convention,
                        sub_sexp.flatten.grep(Position).first.lineno,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
