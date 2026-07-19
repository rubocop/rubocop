# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for modifier cops.
    module StatementModifier
      include LineLengthHelp
      include AllowedPattern

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
        acceptable_line_length?(line_in_modifier_form(node), node.first_line)
      end

      def line_in_modifier_form(node)
        keyword_element = node.loc.keyword
        code_before = keyword_element.source_line[0...keyword_element.column]

        "#{code_before}#{to_modifier_form(node)}#{code_after(node)}"
      end

      # Rather than comparing the rendered modifier form against the bare
      # maximum, ask the question `Layout/LineLength` would: a line the user's
      # configuration exempts (`Layout/LineLength` disabled at that line, an
      # allowed pattern, an allowed cop directive, an allowed URI) fits by
      # definition. This keeps every modifier cop consistent with
      # `Layout/LineLength` instead of each reimplementing part of its policy.
      def acceptable_line_length?(line, line_number)
        return true unless max_line_length
        return true if line_length(line) <= max_line_length
        return true unless line_length_enabled_at_line?(line_number)
        return true if matches_allowed_pattern?(line)

        if allow_cop_directives? && directive_on_source_line?(line_number - 1)
          return line_length_without_directive(line) <= max_line_length
        end

        allowed_by_uri?(line)
      end

      def allowed_by_uri?(line)
        return false unless allow_uri?

        uri_range = find_excessive_range(line, :uri)
        !uri_range.nil? && allowed_position?(line, uri_range)
      end

      def line_length_enabled_at_line?(line)
        processed_source.comment_config.cop_enabled_at_line?('Layout/LineLength', line)
      end

      # `Layout/LineLength`'s allowed patterns, so a modifier line that the
      # user has configured that cop to accept is not flagged for length here.
      def allowed_patterns
        line_length_config = config.for_cop('Layout/LineLength')
        line_length_config['AllowedPatterns'] || line_length_config['IgnoredPatterns'] || []
      end

      def to_modifier_form(node)
        body = if_body_source(node.body)
        expression = [body, node.keyword, node.condition.source].compact.join(' ')
        parenthesized = parenthesize?(node) ? "(#{expression})" : expression
        [parenthesized, first_line_comment(node)].compact.join(' ')
      end

      def if_body_source(if_body)
        if if_body.call_type? && !if_body.method?(:[]=) && omitted_value_in_last_hash_arg?(if_body)
          "#{method_source(if_body)}(#{if_body.arguments.map(&:source).join(', ')})"
        else
          if_body.source
        end
      end

      def omitted_value_in_last_hash_arg?(if_body)
        return false unless (last_argument = if_body.last_argument)

        last_argument.hash_type? && last_argument.pairs.last&.value_omission?
      end

      def method_source(if_body)
        end_range = if_body.implicit_call? ? if_body.loc.dot.end : if_body.loc.selector

        if_body.source_range.begin.join(end_range).source
      end

      def first_line_comment(node)
        comment = processed_source.comment_at_line(node.first_line)
        return unless comment

        comment_source = comment.source
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

      def comment_disables_cop?(comment)
        regexp_pattern = "# rubocop : (disable|todo) ([^,],)* (all|#{cop_name})"
        Regexp.new(regexp_pattern.gsub(' ', '\s*')).match?(comment)
      end
    end
  end
end
