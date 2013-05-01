# encoding: utf-8

module Rubocop
  module Cop
    class BlockComments < Cop
      ERROR_MESSAGE = 'Do not use block comments.'

      def inspect(file, source, tokens, sexp)
        tokens.each do |t|
          if t.type == :on_embdoc_beg
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
