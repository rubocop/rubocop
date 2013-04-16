# encoding: utf-8

module Rubocop
  module Cop
    class StringLiterals < Cop
      ERROR_MESSAGE = "Prefer single-quoted strings when you don't need " +
        'string interpolation or special symbols.'

      def inspect(file, source, tokens, sexp)
        state = :outside
        tokens.each do |t|
          state = case [state, t.type]
                  when [:outside, :on_tstring_beg]
                    :double_quote if t.text == '"'

                  when [:double_quote, :on_tstring_content]
                    :valid_double_quote if t.text =~ /'|\\[ntrx]/

                  when [:double_quote, :on_embexpr_beg]
                    :embedded_expression

                  when [:double_quote, :on_embvar]
                    :embedded_variable

                  when [:double_quote, :on_tstring_end]
                    add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
                    :outside

                  when [:embedded_expression, :on_rbrace]
                    :valid_double_quote

                  when [:embedded_variable, :on_ivar]
                    :valid_double_quote

                  when [:embedded_variable, :on_cvar]
                    :valid_double_quote

                  when [:embedded_variable, :on_gvar]
                    :valid_double_quote

                  when [:valid_double_quote, :on_tstring_end]
                    :outside
            end || state
        end
      end
    end
  end
end
