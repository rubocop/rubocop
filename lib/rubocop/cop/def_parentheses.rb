# encoding: utf-8

module Rubocop
  module Cop
    class DefParentheses < Cop
      ERROR_MESSAGE = ['Use def with parentheses when there are arguments.',
                       "Omit the parentheses in defs when the method " +
                       "doesn't accept any arguments."]
      EMPTY_PARAMS = [:params, nil, nil, nil, nil, nil]

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) do |def_sexp|
          case def_sexp[2][0]
          when :params
            if def_sexp[2] != EMPTY_PARAMS
              add(def_sexp, source, ERROR_MESSAGE[0])
            end
          when :paren
            if def_sexp[2][1] == EMPTY_PARAMS
              add(def_sexp, source, ERROR_MESSAGE[1])
            end
          end
        end
      end

      private

      def add(def_sexp, source, message)
        pos = def_sexp[1][-1]
        index = pos[0] - 1
        add_offence(:convention, index, source[index], message)
      end
    end
  end
end
