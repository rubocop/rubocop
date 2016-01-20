# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common code for indenting literal arrays and hashes.
    module ArrayHashIndentation
      def each_argument_node(node, type)
        _receiver, _method_name, *args = *node
        left_parenthesis = node.loc.begin
        return unless left_parenthesis

        args.each do |arg|
          on_node(type, arg, :send) do |type_node|
            left_brace = type_node.loc.begin
            if left_brace && left_brace.line == left_parenthesis.line
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

        if @column_delta == 0
          # which column was actually used as 'base column' for indentation?
          # (not the column which we think should be the 'base column',
          # but the one which has actually been used for that purpose)
          base_column = actual_column - configured_indentation_width - offset
          styles = detected_styles(base_column, left_parenthesis, left_brace)
          if styles.size > 1
            ambiguous_style_detected(*styles)
          else
            correct_style_detected
          end
        else
          incorrect_style_detected(actual_column, offset, first,
                                   left_parenthesis, left_brace)
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

      def detected_styles(column, left_parenthesis, left_brace)
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

      def incorrect_style_detected(column, offset, first, left_parenthesis,
                                   left_brace)
        add_offense(first, :expression,
                    message(base_description(left_parenthesis))) do
          base_column = column - configured_indentation_width - offset
          styles = detected_styles(base_column, left_parenthesis, left_brace)
          ambiguous_style_detected(*styles)
        end
      end
    end
  end
end
