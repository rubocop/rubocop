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
        return true unless max_line_length

        modifier_length = length_in_modifier_form(node, node.condition,
                                                  node.body.source_length)

        modifier_length <= max_line_length
      end

      def length_in_modifier_form(node, cond, body_length)
        indentation = node.loc.keyword.column * indentation_multiplier
        kw_length = node.loc.keyword.size
        cond_length = cond.source_range.size
        space = 1
        indentation + body_length + space + kw_length + space + cond_length
      end

      def max_line_length
        return unless config.for_cop('Metrics/LineLength')['Enabled']

        config.for_cop('Metrics/LineLength')['Max']
      end

      def indentation_multiplier
        return 1 if config.for_cop('Layout/Tab')['Enabled']

        default_configuration = RuboCop::ConfigLoader.default_configuration
        config.for_cop('Layout/Tab')['IndentationWidth'] ||
          config.for_cop('Layout/IndentationWidth')['Width'] ||
          default_configuration.for_cop('Layout/Tab')['IndentationWidth'] ||
          default_configuration.for_cop('Layout/IndentationWidth')['Width']
      end
    end
  end
end
