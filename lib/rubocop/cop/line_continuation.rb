# encoding: utf-8

module Rubocop
  module Cop
    class LineContinuation < Cop
      ERROR_MESSAGE = 'Avoid the use of the line continuation character(/).'

      def inspect(file, source, tokens, sexp)
        tokens.each_index do |ix|
          t = tokens[ix]
          if t.type == :on_sp && t.text == "\\\n"
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
