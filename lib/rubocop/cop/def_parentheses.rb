# encoding: utf-8

module Rubocop
  module Cop
    class DefParentheses < Cop
      ERROR_MESSAGE = ['Use def with parentheses when there are arguments.',
                       'Omit the parentheses in defs when the method ' +
                       "doesn't accept any arguments."]
      EMPTY_PARAMS = [:params, nil, nil, nil, nil, nil]

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) do |def_sexp|
          pos = def_sexp[1][-1]
          case def_sexp[2][0]
          when :params
            if def_sexp[2] != EMPTY_PARAMS
              add_offence(:convention, pos.lineno, ERROR_MESSAGE[0])
            end
          when :paren
            if def_sexp[2][1] == EMPTY_PARAMS
              method_name_ix = tokens.index { |t| t.pos == pos }
              start = method_name_ix + 1
              rparen_ix = start + tokens[start..-1].index { |t| t.text == ')' }
              first_body_token = tokens[(rparen_ix + 1)..-1].find do |t|
                not whitespace?(t)
              end
              if first_body_token.pos.lineno > pos.lineno
                # Only report offence if there's a line break after
                # the empty parens.
                add_offence(:convention, pos.lineno, ERROR_MESSAGE[1])
              end
            end
          end
        end
      end
    end
  end
end
