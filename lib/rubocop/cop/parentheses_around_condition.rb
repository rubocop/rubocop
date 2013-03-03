# encoding: utf-8

module Rubocop
  module Cop
    class ParenthesesAroundCondition < Cop
      ERROR_MESSAGE = "Don't use parentheses around the condition of an " +
        'if/unless/while/until, unless the condition contains an assignment.'

      def inspect(file, source, tokens, sexp)
        [:if, :elsif, :unless, :while, :until,
         :if_mod, :unless_mod, :while_mod, :until_mod].each do |keyword|
          each(keyword, sexp) do |s|
            if s[1][0] == :paren && s[1][1][0][0] != :assign
              positions = all_positions(s[1])
              if positions.first.lineno == positions.last.lineno
                add_offence(:convention, positions.first.lineno, ERROR_MESSAGE)
              end
            end
          end
        end
      end
    end
  end
end
