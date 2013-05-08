# encoding: utf-8

module Rubocop
  module Cop
    module DefParentheses
      EMPTY_PARAMS = [:params, nil, nil, nil,
        nil, nil, nil, nil] if RUBY_VERSION >= '2.0.0'
      EMPTY_PARAMS = [:params, nil, nil, nil,
        nil, nil] if RUBY_VERSION < '2.0.0'

      def inspect(file, source, tokens, sexp)
        each(:def, sexp) { |def_sexp| check(tokens, def_sexp) }
      end
    end

    class DefWithParentheses < Cop
      include DefParentheses
      def error_message
        "Omit the parentheses in defs when the method doesn't accept any " +
          'arguments.'
      end

      def check(tokens, def_sexp)
        if def_sexp[2][0] == :paren && def_sexp[2][1] == EMPTY_PARAMS
          pos = def_sexp[1][-1]
          method_name_ix = tokens.index { |t| t.pos == pos }
          start = method_name_ix + 1
          rparen_ix = start + tokens[start..-1].index { |t| t.text == ')' }
          first_body_token = tokens[(rparen_ix + 1)..-1].find do |t|
            !whitespace?(t)
          end
          if first_body_token.pos.lineno > pos.lineno
            # Only report offence if there's a line break after
            # the empty parens.
            add_offence(:convention, pos.lineno, error_message)
          end
        end
      end
    end

    class DefWithoutParentheses < Cop
      include DefParentheses
      def error_message
        'Use def with parentheses when there are arguments.'
      end

      def check(tokens, def_sexp)
        if def_sexp[2][0] == :params && def_sexp[2] != EMPTY_PARAMS
          add_offence(:convention, def_sexp[1][-1].lineno, error_message)
        end
      end
    end
  end
end
