# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks the indentation of the first element in an array literal
      # where the opening bracket and the first element are on separate lines.
      # The other elements' indentations are handled by the AlignArray cop.
      #
      # By default, array literals that are arguments in a method call with
      # parentheses, and where the opening square bracket of the array is on the
      # same line as the opening parenthesis of the method call, shall have
      # their first element indented one step (two spaces) more than the
      # position inside the opening parenthesis.
      #
      # Other array literals shall have their first element indented one step
      # more than the start of the line where the opening square bracket is.
      #
      # This default style is called 'special_inside_parentheses'. Alternative
      # styles are 'consistent' and 'align_brackets'. Here are examples:
      #
      #     # special_inside_parentheses
      #     array = [
      #       :value
      #     ]
      #     but_in_a_method_call([
      #                            :its_like_this
      #                          ])
      #     # consistent
      #     array = [
      #       :value
      #     ]
      #     and_in_a_method_call([
      #       :no_difference
      #     ])
      #     # align_brackets
      #     and_now_for_something = [
      #                               :completely_different
      #                             ]
      #
      class IndentArray < Cop
        include AutocorrectAlignment
        include ConfigurableEnforcedStyle

        def on_array(node)
          left_bracket = node.loc.begin
          check(node, left_bracket, nil) if left_bracket
        end

        def on_send(node)
          _receiver, _method_name, *args = *node
          left_parenthesis = node.loc.begin
          return unless left_parenthesis

          args.each do |arg|
            on_node(:array, arg, :send) do |array_node|
              left_bracket = array_node.loc.begin
              if left_bracket && left_bracket.line == left_parenthesis.line
                check(array_node, left_bracket, left_parenthesis)
                ignore_node(array_node)
              end
            end
          end
        end

        private

        def check(array_node, left_bracket, left_parenthesis)
          return if ignored_node?(array_node)

          first_elem = array_node.children.first
          if first_elem
            left_bracket = array_node.loc.begin
            return if first_elem.source_range.line == left_bracket.line
            check_first_elem(first_elem, left_bracket, left_parenthesis, 0)
          end

          check_right_bracket(array_node.loc.end, left_bracket,
                              left_parenthesis)
        end

        def check_right_bracket(right_bracket, left_bracket, left_parenthesis)
          # if the right bracket is on the same line as the last value, accept
          return if right_bracket.source_line[0...right_bracket.column] =~ /\S/

          expected_column = base_column(left_bracket, left_parenthesis)
          @column_delta = expected_column - right_bracket.column
          return if @column_delta == 0

          msg = if style == :align_brackets
                  'Indent the right bracket the same as the left bracket.'
                elsif style == :special_inside_parentheses && left_parenthesis
                  'Indent the right bracket the same as the first position ' \
                  'after the preceding left parenthesis.'
                else
                  'Indent the right bracket the same as the start of the line' \
                  ' where the left bracket is.'
                end
          add_offense(right_bracket, right_bracket, msg)
        end

        def check_first_elem(first_elem, left_bracket, left_parenthesis, offset)
          actual_column = first_elem.source_range.column
          expected_column = base_column(left_bracket, left_parenthesis) +
                            configured_indentation_width + offset
          @column_delta = expected_column - actual_column

          if @column_delta == 0
            # which column was actually used as 'base column' for indentation?
            # (not the column which we think should be the 'base column',
            # but the one which has actually been used for that purpose)
            base_column = actual_column - configured_indentation_width - offset
            styles = detected_styles(base_column, left_parenthesis,
                                     left_bracket)
            if styles.size > 1
              ambiguous_style_detected(*styles)
            else
              correct_style_detected
            end
          else
            incorrect_style_detected(actual_column, offset, first_elem,
                                     left_parenthesis, left_bracket)
          end
        end

        def incorrect_style_detected(column, offset, first_elem,
                                     left_parenthesis, left_bracket)
          add_offense(first_elem, :expression,
                      message(base_description(left_parenthesis))) do
            base_column = column - configured_indentation_width - offset
            styles = detected_styles(base_column, left_parenthesis,
                                     left_bracket)
            ambiguous_style_detected(*styles)
          end
        end

        def detected_styles(column, left_parenthesis, left_bracket)
          styles = []
          if column == (left_bracket.source_line =~ /\S/)
            styles << :consistent
            styles << :special_inside_parentheses unless left_parenthesis
          end
          if left_parenthesis && column == left_parenthesis.column + 1
            styles << :special_inside_parentheses
          end
          styles << :align_brackets if column == left_bracket.column
          styles
        end

        def base_column(left_bracket, left_parenthesis)
          if style == :align_brackets
            left_bracket.column
          elsif left_parenthesis && style == :special_inside_parentheses
            left_parenthesis.column + 1
          else
            left_bracket.source_line =~ /\S/
          end
        end

        # Returns the description of what the correct indentation is based on.
        def base_description(left_parenthesis)
          if style == :align_brackets
            'the position of the opening bracket'
          elsif left_parenthesis && style == :special_inside_parentheses
            'the first position after the preceding left parenthesis'
          else
            'the start of the line where the left square bracket is'
          end
        end

        def message(base_description)
          format('Use %d spaces for indentation in an array, relative to %s.',
                 configured_indentation_width, base_description)
        end
      end
    end
  end
end
