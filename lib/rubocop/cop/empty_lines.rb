# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLines < Cop
      ERROR_MESSAGE = 'Extra blank line detected.'

      def inspect(file, source, tokens, sexp)
        previous_token = Token.new(0, :init, '')

        tokens.each do |t|
          if t.type == :on_ignored_nl && previous_token.type == :on_ignored_nl
            add_offence(:convention,
                        t.pos.lineno,
                        ERROR_MESSAGE)
          end

          previous_token = t
        end
      end
    end
  end
end
