# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLines < Cop
      MSG = 'Extra blank line detected.'
      LINE_OFFSET = 2

      def inspect(file, source, tokens, sexp)
        prev_line = tokens.first.pos.lineno

        tokens.each do |token|
          cur_line = token.pos.lineno
          line_diff = cur_line - prev_line
          puts line_diff

          if line_diff > LINE_OFFSET
            ((prev_line + LINE_OFFSET)...cur_line).each do |line|
              add_offence(:convention, line, MSG)
            end
          end

          prev_line = cur_line
        end
      end
    end
  end
end
