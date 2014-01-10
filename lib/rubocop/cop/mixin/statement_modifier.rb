# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      include IfNode

      # TODO: Extremely ugly solution that needs lots of polish.
      def check(sexp, comments)
        case sexp.loc.keyword.source
        when 'if'     then cond, body, _else = *sexp
        when 'unless' then cond, _else, body = *sexp
        else               cond, body = *sexp
        end

        return false if length(sexp) > 3

        body_length = body_length(body)

        return false if body_length == 0

        on_node(:lvasgn, cond) do
          return false
        end

        indentation = sexp.loc.keyword.column
        kw_length = sexp.loc.keyword.size
        cond_length = cond.loc.expression.size
        space = 1
        total = indentation + body_length + space + kw_length + space +
          cond_length
        total <= max_line_length && !body_has_comment?(body, comments)
      end

      def max_line_length
        config.for_cop('LineLength')['Max']
      end

      def length(sexp)
        sexp.loc.expression.source.lines.to_a.size
      end

      def body_length(body)
        if body && body.loc.expression
          body.loc.expression.size
        else
          0
        end
      end

      def body_has_comment?(body, comments)
        comment_lines = comments.map(&:location).map(&:line)
        body_line = body.loc.expression.line
        comment_lines.include?(body_line)
      end
    end
  end
end
