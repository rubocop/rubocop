# encoding: utf-8

module Rubocop
  module Cop
    class SpaceAfterCommaEtc < Cop
      ERROR_MESSAGE = 'Space missing after %s.'

      def inspect(file, source, tokens, sexp)
        tokens.each_index do |ix|
          t = tokens[ix]
          kind = case t.type
                 when :on_comma     then 'comma'
                 when :on_label     then 'colon'
                 when :on_op        then 'colon' if t.text == ':'
                 when :on_semicolon then 'semicolon'
                 end
          if kind and not [:on_sp,
                           :on_ignored_nl].include?(tokens[ix + 1].type)
            add_offence(:convention, t.pos.lineno, ERROR_MESSAGE % kind)
          end
        end
      end
    end
  end
end
