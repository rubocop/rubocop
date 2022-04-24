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
        node.modifier_form? ||
          node.nonempty_line_count > 3 ||
          processed_source.line_with_comment?(node.loc.last_line) ||
          (first_line_comment(node) && code_after(node))
      end

      def non_eligible_body?(body)
        body.nil? ||
          body.empty_source? ||
          body.begin_type? ||
          processed_source.contains_comment?(body.source_range)
      end

      def non_eligible_condition?(condition)
        condition.each_node.any?(&:lvasgn_type?)
      end

      def modifier_fits_on_single_line?(node)
        return true unless max_line_length

        length_in_modifier_form(node) <= max_line_length
      end

      def length_in_modifier_form(node)
        keyword_element = node.loc.keyword
        code_before = keyword_element.source_line[0...keyword_element.column]
        expression = to_modifier_form(node)
        line_length("#{code_before}#{expression}#{code_after(node)}")
      end

      def to_modifier_form(node)
        expression = [node.body.source, node.keyword, node.condition.source].compact.join(' ')
        parenthesized = parenthesize?(node) ? "(#{expression})" : expression
        [parenthesized, first_line_comment(node)].compact.join(' ')
      end

      def first_line_comment(node)
        comment = processed_source.find_comment { |c| same_line?(c, node) }
        return unless comment

        comment_source = comment.loc.expression.source
        comment_source unless comment_disables_cop?(comment_source)
      end

      def code_after(node)
        end_element = node.loc.end
        code = end_element.source_line[end_element.last_column..]
        code unless code.empty?
      end

      def parenthesize?(node)
        # Parenthesize corrected expression if changing to modifier-if form
        # would change the meaning of the parent expression
        # (due to the low operator precedence of modifier-if)
        parent = node.parent
        return false if parent.nil?
        return true if parent.assignment? || parent.operator_keyword?
        return true if %i[array pair].include?(parent.type)

        node.parent.send_type?
      end

      def max_line_length
        return unless config.for_cop('Layout/LineLength')['Enabled']

        config.for_cop('Layout/LineLength')['Max']
      end

      def comment_disables_cop?(comment)
        regexp_pattern = "# rubocop : (disable|todo) ([^,],)* (all|#{cop_name})"
        Regexp.new(regexp_pattern.gsub(' ', '\s*')).match?(comment)
      end
    end
  end
end
