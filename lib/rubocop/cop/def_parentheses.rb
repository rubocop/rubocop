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
          pos = def_sexp[1][-1]
          case def_sexp[2][0]
          when :params
            add(pos, source, ERROR_MESSAGE[0]) if def_sexp[2] != EMPTY_PARAMS
          when :paren
            if def_sexp[2][1] == EMPTY_PARAMS
              method_name_ix = tokens.index { |t| t[0] == pos }
              start = method_name_ix + 1
              rparen_ix = start + tokens[start..-1].index { |t| t[2] == ')' }
              first_body_token = tokens[(rparen_ix + 1)..-1].find do |t|
                not whitespace?(t)
              end
              if first_body_token[0][0] > pos[0]
                # Only report offence if there's a line break after
                # the empty parens.
                add(pos, source, ERROR_MESSAGE[1])
              end
            end
          end
        end
      end

      private

      def add(pos, source, message)
        index = pos[0] - 1
        add_offence(:convention, index, source[index], message)
      end
    end
  end
end
