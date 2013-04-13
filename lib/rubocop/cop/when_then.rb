# encoding: utf-8

module Rubocop
  module Cop
    class WhenThen < Cop
      ERROR_MESSAGE = 'Never use "when x;". Use "when x then" instead.'

      def inspect(file, source, tokens, sexp)
        each(:when, sexp) do |s|
          # The grammar is:
          # when <value> <divider> <body>
          # where divider is either semicolon, then, or line break.
          last_pos_in_value = all_positions(s[1])[-1]

          next unless last_pos_in_value # Give up if no positions found.

          start_index = tokens.index { |t| t.pos == last_pos_in_value }
          tokens[start_index..-1].each do |t|
            break if ['then', "\n"].include?(t.text)
            if t.type == :on_semicolon
              add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
