# encoding: utf-8

module Rubocop
  module Cop
    class AsciiIdentifiersAndComments < Cop
      ERROR_MESSAGE = 'Use only ascii symbols in identifiers and comments.'

      def inspect(file, source, tokens, sexp)
        tokens.each do |t|
          if [:on_ident, :on_comment].include?(t.type) &&
              t.text =~ /[^\x00-\x7f]/
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
