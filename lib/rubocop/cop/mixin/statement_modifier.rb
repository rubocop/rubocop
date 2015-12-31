# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      include IfNode

      def fit_within_line_as_modifier_form?(node)
        cond, body, _else = if_node_parts(node)

        return false if length(node) > 3
        return false if body && body.begin_type? # multiple statements

        body_length = body_length(body)

        return false if body_length == 0
        return false if cond.each_node.any?(&:lvasgn_type?)
        return false if body_has_comment?(body)
        return false if end_keyword_has_comment?(node)

        indentation = node.loc.keyword.column
        kw_length = node.loc.keyword.size
        cond_length = cond.source_range.size
        space = 1
        total = indentation + body_length + space + kw_length + space +
                cond_length

        total <= max_line_length
      end

      def max_line_length
        cop_config['MaxLineLength'] ||
          config.for_cop('Metrics/LineLength')['Max']
      end

      def length(node)
        node.source.lines.grep(/\S/).size
      end

      def body_length(body)
        if body && body.source_range
          body.source_range.size
        else
          0
        end
      end

      def body_has_comment?(body)
        comment_lines.include?(body.source_range.line)
      end

      def end_keyword_has_comment?(node)
        comment_lines.include?(node.loc.end.line)
      end

      def comment_lines
        @comment_lines ||= processed_source.comments.map { |c| c.location.line }
      end
    end
  end
end
