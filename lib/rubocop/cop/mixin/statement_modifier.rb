# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      def single_line_as_modifier?(node)
        return false if non_eligible_node?(node) ||
                        non_eligible_body?(node.body) ||
                        non_eligible_condition?(node.condition)

        modifier_fits_on_single_line?(node)
      end

      def non_eligible_node?(node)
        line_count(node) > 3 ||
          !node.modifier_form? && commented?(node.loc.end)
      end

      def non_eligible_body?(body)
        empty_body?(body) || body.begin_type? || commented?(body.source_range)
      end

      def non_eligible_condition?(condition)
        condition.each_node.any?(&:lvasgn_type?)
      end

      def modifier_fits_on_single_line?(node)
        modifier_length = length_in_modifier_form(node, node.condition,
                                                  body_length(node.body))

        modifier_length <= max_line_length
      end

      def length_in_modifier_form(node, cond, body_length)
        indentation = node.loc.keyword.column
        kw_length = node.loc.keyword.size
        cond_length = cond.source_range.size
        space = 1
        indentation + body_length + space + kw_length + space + cond_length
      end

      def max_line_length
        cop_config['MaxLineLength'] ||
          config.for_cop('Metrics/LineLength')['Max']
      end

      def line_count(node)
        node.source.lines.grep(/\S/).size
      end

      def empty_body?(body)
        !body || body_length(body).zero?
      end

      def body_length(body)
        body.source_range ? body.source_range.size : 0
      end

      def commented?(source)
        comment_lines.include?(source.line)
      end

      def comment_lines
        @comment_lines ||= processed_source.comments.map { |c| c.location.line }
      end
    end
  end
end
