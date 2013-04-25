# encoding: utf-8

module Rubocop
  module Cop
    class AsciiComments < Cop
      ERROR_MESSAGE = 'Use only ascii symbols in comments.'

      def inspect(file, source, tokens, sexp)
        tokens.each do |t|
          if t.type == :on_comment &&
              t.text =~ /[^\x00-\x7f]/
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
