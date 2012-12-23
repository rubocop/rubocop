# encoding: utf-8

module Rubocop
  module Cop
    class NumericLiterals < Cop
      ERROR_MESSAGE = 'Add underscores to large numeric literals to ' +
        'improve their readability.'

      def inspect(file, source, tokens, sexp)
        tokens.each do |pos, name, text|
          if [:on_int, :on_float].include?(name) &&
              text.split('.').grep(/\d{6}/).any?
            index = pos[0] - 1
            add_offence(:convention, index, source[index], ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
