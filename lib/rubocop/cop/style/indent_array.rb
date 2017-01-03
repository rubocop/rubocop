# frozen_string_literal: true

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
        include ArrayHashIndentation

        def on_array(node)
          check(node, nil) if node.loc.begin
        end

        def on_send(node)
          each_argument_node(node, :array) do |array_node, left_parenthesis|
            check(array_node, left_parenthesis)
          end
        end

        private

        def brace_alignment_style
          :align_brackets
        end

        def check(array_node, left_parenthesis)
          return if ignored_node?(array_node)

          left_bracket = array_node.loc.begin
          first_elem = array_node.values.first
          if first_elem
            return if first_elem.source_range.line == left_bracket.line
            check_first(first_elem, left_bracket, left_parenthesis, 0)
          end

          check_right_bracket(array_node.loc.end, left_bracket,
                              left_parenthesis)
        end

        def check_right_bracket(right_bracket, left_bracket, left_parenthesis)
          # if the right bracket is on the same line as the last value, accept
          return if right_bracket.source_line[0...right_bracket.column] =~ /\S/

          expected_column = base_column(left_bracket, left_parenthesis)
          @column_delta = expected_column - right_bracket.column
          return if @column_delta.zero?

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
