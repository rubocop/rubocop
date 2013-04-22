# encoding: utf-8

module Rubocop
  module Cop
    class FavorPercentR < Cop
      ERROR_MESSAGE = 'Use %r for regular expressions matching more ' +
        "than one '/' character."

      def inspect(file, source, tokens, sexp)
        tokens.each_cons(2) do |t1, t2|
          if t1.type == :on_regexp_beg && t1.text == '/' &&
              t2.text.scan(/\//).size > 1
            add_offence(:convention, t1.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
