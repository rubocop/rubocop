# encoding: utf-8

module Rubocop
  module Cop
    class ColonMethodCall < Cop
      ERROR_MESSAGE = 'Do not use :: for method invocation.'

      def inspect(file, source, tokens, sexp)
        state = :outside
        tokens.each do |t|
          state = case [state, t.type]
                  when [:outside, :on_const]
                    :const

                  when [:outside, :on_ident]
                    :ident

                  when [:const, :on_op]
                    t.text == '::' ? :const_colon : :outside

                  when [:ident, :on_op]
                    t.text == '::' ? :ident_colon : :outside

                  when [:ident_colon, :on_ident]
                    add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
                    :ident

                  when [:const_colon, :on_ident]
                    add_offence(:convention, t.pos.lineno, ERROR_MESSAGE)
                    :ident

                  when [:ident_colon, :on_const]
                    :const

                  when [:const_colon, :on_const]
                    :const
                  else
                    :outside
            end || state
        end
      end
    end
  end
end
