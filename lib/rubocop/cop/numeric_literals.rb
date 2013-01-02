# encoding: utf-8

module Rubocop
  module Cop
    class NumericLiterals < Cop
      ERROR_MESSAGE = 'Add underscores to large numeric literals to ' +
        'improve their readability.'

      def inspect(file, source, tokens, sexp)
        tokens.each do |t|
          if [:on_int, :on_float].include?(t.type) &&
              t.text.split('.').grep(/\d{6}/).any?
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
