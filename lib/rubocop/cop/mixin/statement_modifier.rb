# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      private

      def single_line_as_modifier?(node)
        return false if non_eligible_node?(node) ||
                        non_eligible_body?(node.body) ||
                        non_eligible_condition?(node.condition)

        modifier_fits_on_single_line?(node)
      end

      def non_eligible_node?(node)
        node.nonempty_line_count > 3 ||
          !node.modifier_form? &&
            processed_source.commented?(node.loc.end)
      end

      def non_eligible_body?(body)
        body.nil? ||
          body.empty_source? ||
          body.begin_type? ||
          processed_source.commented?(body.source_range)
      end

      def non_eligible_condition?(condition)
        condition.each_node.any?(&:lvasgn_type?)
      end

      def modifier_fits_on_single_line?(node)
        modifier_length = length_in_modifier_form(node, node.condition,
                                                  node.body.source_length)

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
        config.for_cop('Metrics/LineLength')['Max']
      end
    end
  end
end
