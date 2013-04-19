# encoding: utf-8

module Rubocop
  module Cop
    class EnsureReturn < Cop
      ERROR_MESSAGE = 'Never return from an ensure block.'

      def inspect(file, source, tokens, sexp)
        in_ensure = false
        ensure_col = nil

        tokens.each_index do |ix|
          t = tokens[ix]
          if ensure_start?(t)
            in_ensure = true
            ensure_col = t.pos.column
          elsif ensure_end?(t, ensure_col)
            in_ensure = false
          elsif in_ensure && t.type == :on_kw && t.text == 'return'
            add_offence(:warning, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end

      private

      def ensure_start?(t)
        t.type == :on_kw && t.text == 'ensure'
      end

      def ensure_end?(t, column)
        t.type == :on_kw && t.text == 'end' && t.pos.column == column
      end
    end
  end
end
