# encoding: utf-8

module Rubocop
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
          first_pair = node.children.first
          return if first_pair.nil?

          left_bracket = node.loc.begin
          return if left_bracket.nil?

          return if first_pair.loc.expression.line == left_bracket.line

          column = first_pair.loc.expression.column
          base_column = left_bracket.source_line =~ /\S/
          expected_column = base_column + IndentationWidth::CORRECT_INDENTATION
          @column_delta = expected_column - column

          add_offense(first_pair, :expression) if @column_delta != 0
        end

        def message(_)
          format('Use %d spaces for indentation in an array, relative to ' \
                 'the start of the line where the left bracket is.',
                 IndentationWidth::CORRECT_INDENTATION)
        end
      end
    end
  end
end
