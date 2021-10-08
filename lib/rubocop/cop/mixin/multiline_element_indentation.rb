# frozen_string_literal: true

module RuboCop
  module Cop
    # Common code for indenting the first elements in multiline
    # array literals, hash literals, and method definitions.
    module MultilineElementIndentation
      private

      def each_argument_node(node, type)
        left_parenthesis = node.loc.begin

        return unless left_parenthesis

        node.arguments.each do |arg|
          on_node(type, arg, :send) do |type_node|
            left_brace = type_node.loc.begin
            if left_brace && same_line?(left_brace, left_parenthesis)
              yield type_node, left_parenthesis
              ignore_node(type_node)
            end
          end
        end
      end

      def check_first(first, left_brace, left_parenthesis, offset)
        actual_column = first.source_range.column
        expected_column = base_column(left_brace, left_parenthesis) +
                          configured_indentation_width + offset
        @column_delta = expected_column - actual_column
        styles = detected_styles(actual_column, offset, left_parenthesis, left_brace)

        if @column_delta.zero?
          check_expected_style(styles)
        else
          incorrect_style_detected(styles, first, left_parenthesis)
        end
      end

      def check_expected_style(styles)
        if styles.size > 1
          ambiguous_style_detected(*styles)
        else
          correct_style_detected
        end
      end

      def base_column(left_brace, left_parenthesis)
        if style == brace_alignment_style
          left_brace.column
        elsif left_parenthesis && style == :special_inside_parentheses
          left_parenthesis.column + 1
        else
          left_brace.source_line =~ /\S/
        end
      end

      def detected_styles(actual_column, offset, left_parenthesis, left_brace)
        base_column = actual_column - configured_indentation_width - offset
        detected_styles_for_column(base_column, left_parenthesis, left_brace)
      end

      def detected_styles_for_column(column, left_parenthesis, left_brace)
        styles = []
        if column == (left_brace.source_line =~ /\S/)
          styles << :consistent
          styles << :special_inside_parentheses unless left_parenthesis
        end
        if left_parenthesis && column == left_parenthesis.column + 1
          styles << :special_inside_parentheses
        end
        styles << brace_alignment_style if column == left_brace.column
        styles
      end

      def incorrect_style_detected(styles, first, left_parenthesis)
        msg = message(base_description(left_parenthesis))

        add_offense(first, message: msg) do |corrector|
          autocorrect(corrector, first)

          ambiguous_style_detected(*styles)
        end
      end
    end
  end
end
