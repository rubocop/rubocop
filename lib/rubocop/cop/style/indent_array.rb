# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cops checks the indentation of the first element in an array
      # literal where the opening bracket and the first element are on separate
      # lines. The other elements' indentations are handled by the AlignArray
      # cop.
      #
      # Array literals shall have their first element indented one step (2
      # spaces) more than the start of the line where the opening bracket is.
      class IndentArray < Cop
        include AutocorrectAlignment

        def on_array(node)
          left_bracket = node.loc.begin
          return if left_bracket.nil?

          first_pair = node.children.first
          check_first_pair(first_pair, left_bracket)
          check_right_bracket(node, first_pair, left_bracket)
        end

        def check_first_pair(first_pair, left_bracket)
          return if first_pair.nil?
          expr = first_pair.loc.expression
          return if expr.line == left_bracket.line

          base_column = left_bracket.source_line =~ /\S/
          expected_column = base_column + configured_indentation_width
          @column_delta = expected_column - expr.column
          return if @column_delta == 0

          msg = format('Use %d spaces for indentation in an array, relative ' \
                       'to the start of the line where the left bracket is.',
                       configured_indentation_width)
          add_offense(first_pair, :expression, msg)
        end

        def check_right_bracket(node, first_pair, left_bracket)
          right_bracket = node.loc.end
          column = right_bracket.column
          return if right_bracket.source_line[0...column] =~ /\S/

          if first_pair && first_pair.loc.expression.line == left_bracket.line
            base_column = left_bracket.column
            expected_indentation = 'the left bracket'
          else
            base_column = left_bracket.source_line =~ /\S/
            expected_indentation =
              'the start of the line where the left bracket is'
          end
          @column_delta = base_column - column
          return if @column_delta == 0

          add_offense(right_bracket, right_bracket,
                      'Indent the right bracket the same as ' +
                      expected_indentation + '.')
        end
      end
    end
  end
end
