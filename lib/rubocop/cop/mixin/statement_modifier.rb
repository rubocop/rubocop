# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      include IfNode

      # TODO: Extremely ugly solution that needs lots of polish.
      def fit_within_line_as_modifier_form?(node)
        case node.loc.keyword.source
        when 'if'     then cond, body, _else = *node
        when 'unless' then cond, _else, body = *node
        else               cond, body = *node
        end

        return false if length(node) > 3

        body_length = body_length(body)

        return false if body_length == 0

        return false if cond.each_node.any?(&:lvasgn_type?)

        indentation = node.loc.keyword.column
        kw_length = node.loc.keyword.size
        cond_length = cond.loc.expression.size
        space = 1
        total = indentation + body_length + space + kw_length + space +
                cond_length
        total <= max_line_length && !body_has_comment?(body)
      end

      def max_line_length
        cop_config && cop_config['MaxLineLength'] ||
          config.for_cop('Metrics/LineLength')['Max']
      end

      def length(node)
        node.loc.expression.source.lines.to_a.size
      end

      def body_length(body)
        if body && body.loc.expression
          body.loc.expression.size
        else
          0
        end
      end

      def body_has_comment?(body)
        comment_lines = processed_source.comments.map(&:location).map(&:line)
        body_line = body.loc.expression.line
        comment_lines.include?(body_line)
      end
    end
  end
end
