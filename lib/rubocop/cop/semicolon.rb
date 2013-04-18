# encoding: utf-8

module Rubocop
  module Cop
    class Semicolon < Cop
      ERROR_MESSAGE = 'Do not use semicolons to terminate expressions.'

      def inspect(file, source, tokens, sexp)
        tokens.each_index do |ix|
          t = tokens[ix]
          if t.type == :on_semicolon
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
