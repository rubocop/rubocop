# encoding: utf-8

module Rubocop
  module Cop
    class Alias < Cop
      ERROR_MESSAGE = 'Use alias_method instead of alias.'

      def inspect(file, source, tokens, sexp)
        # we need to keep track of the previous token to avoid
        # interpreting :alias as the keyword alias
        prev = Token.new(0, :init, '')

        tokens.each do |t|
          if prev.type != :on_symbeg && t.type == :on_kw && t.text == 'alias'
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end

          prev = t
        end
      end
    end
  end
end
