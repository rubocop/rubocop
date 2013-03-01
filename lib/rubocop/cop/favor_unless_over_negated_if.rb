# encoding: utf-8

module Rubocop
  module Cop
    module FavorOtherKeywordOverNegation
      private
      def check(grammar_part, sexp)
        each(grammar_part, sexp) do |s|
          # Don't complain about negative if/else. We don't want unless/else.
          next if s[3] && [:else, :elsif].include?(s[3][0])

          condition = s[1]
          condition = condition[1][0] while condition[0] == :paren

          if condition[0] == :unary && [:!, :not].include?(condition[1])
            add_offence(:convention, all_positions(s).first.lineno,
                        error_message)
          end
        end
      end
    end

    class FavorUnlessOverNegatedIf < Cop
      include FavorOtherKeywordOverNegation

      def error_message
        'Favor unless (or control flow or) over if for negative conditions.'
      end

      def inspect(file, source, tokens, sexp)
        [:if, :if_mod].each { |grammar_part| check(grammar_part, sexp) }
      end
    end

    class FavorUntilOverNegatedWhile < Cop
      include FavorOtherKeywordOverNegation

      def error_message
        'Favor until over while for negative conditions.'
      end

      def inspect(file, source, tokens, sexp)
        [:while, :while_mod].each { |grammar_part| check(grammar_part, sexp) }
      end
    end
  end
end
