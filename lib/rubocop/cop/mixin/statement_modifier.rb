# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      include LineLengthHelp

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
        return true unless max_line_length

        length_in_modifier_form(node, node.condition) <= max_line_length
      end

      def length_in_modifier_form(node, cond)
        keyword = node.loc.keyword
        line_before_condition, = keyword.source_line.split(keyword.source)
        condition_source = "#{node.body.source} #{keyword.source} #{cond.source}"
        source = line_before_condition + condition_source
        line_length(source)
      end

      def max_line_length
        return unless config.for_cop('Layout/LineLength')['Enabled']

        config.for_cop('Layout/LineLength')['Max']
      end
    end
  end
end
