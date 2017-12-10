# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that brackets used for array literals have or don't have
      # surrounding space depending on configuration.
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that array literals have
      #   # surrounding space.
      #
      #   # bad
      #   array = [a, b, c, d]
      #
      #   # good
      #   array = [ a, b, c, d ]
      #
      # @example EnforcedStyle: no_space
      #   # The `no_space` style enforces that array literals have
      #   # no surrounding space.
      #
      #   # bad
      #   array = [ a, b, c, d ]
      #
      #   # good
      #   array = [a, b, c, d]
      #
      # @example EnforcedStyle: compact
      #   # The `compact` style normally requires a space inside
      #   # array brackets, with the exception that successive left
      #   # or right brackets are collapsed together in nested arrays.
      #
      #   # bad
      #   array = [ a, [ b, c ] ]
      #
      #   # good
      #   array = [ a, [ b, c ]]
      class SpaceInsideArrayLiteralBrackets < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = '%<command>s space inside array brackets.'.freeze
        EMPTY_MSG = '%<command>s space inside empty array brackets.'.freeze

        def on_array(node)
          return unless node.square_brackets?
          left, right = array_brackets(node)
          if empty_brackets?(left, right)
            return empty_offenses(node, left, right)
          end

          start_ok = next_to_newline?(node, left)
          end_ok = node.single_line? ? false : end_has_own_line?(right)

          issue_offenses(node, left, right, start_ok, end_ok)
        end

        def autocorrect(node)
          left, right = array_brackets(node)

          lambda do |corrector|
            if empty_brackets?(left, right)
              empty_corrections(corrector, left, right)
            elsif style == :no_space
              no_space_corrector(corrector, left, right)
            elsif style == :space
              space_corrector(corrector, left, right)
            else
              compact_corrections(corrector, node, left, right)
            end
          end
        end

        private

        def array_brackets(node)
          [left_array_bracket(node), right_array_bracket(node)]
        end

        def left_array_bracket(node)
          tokens(node).find { |token| left_bracket?(token) }
        end

        def right_array_bracket(node)
          tokens(node).reverse.find { |token| right_bracket?(token) }
        end

        def empty_brackets?(left, right)
          processed_source.tokens.index(left) ==
            processed_source.tokens.index(right) - 1
        end

        def empty_offenses(node, left, right)
          empty_offense(node, 'Use one') if offending_empty_space?(left, right)
          return unless offending_empty_no_space?(left, right)
          empty_offense(node, 'Do not use')
        end

        def empty_offense(node, command)
          add_offense(node, message: format(EMPTY_MSG, command: command))
        end

        def offending_empty_space?(left, right)
          empty_config == 'space' && !space_between?(left, right)
        end

        def offending_empty_no_space?(left, right)
          empty_config == 'no_space' && !no_space_between?(left, right)
        end

        def space_between?(left, right)
          left.end_pos + 1 == right.begin_pos
        end

        def no_space_between?(left, right)
          left.end_pos == right.begin_pos
        end

        def empty_config
          cop_config['EnforcedStyleForEmptyBrackets']
        end

        def empty_corrections(corrector, left, right)
          if offending_empty_space?(left, right)
            range = side_space_range(range: left.pos, side: :right)
            corrector.remove(range)
            corrector.insert_after(left.pos, ' ')
          elsif offending_empty_no_space?(left, right)
            range = side_space_range(range: left.pos, side: :right)
            corrector.remove(range)
          end
        end

        def next_to_newline?(node, token)
          tokens(node)[index_for(node, token) + 1].line != token.line
        end

        def end_has_own_line?(token)
          line, col = line_and_column_for(token)
          return true if col == -1
          processed_source.lines[line][0..col].delete(' ').empty?
        end

        def index_for(node, token)
          tokens(node).index(token)
        end

        def line_and_column_for(token)
          [token.line - 1, token.column - 1]
        end

        def issue_offenses(node, left, right, start_ok, end_ok)
          if style == :no_space
            start_ok = next_to_comment?(node, left)
            no_space_offenses(node, left, right, MSG, start_ok: start_ok,
                                                      end_ok: end_ok)
          elsif style == :space
            space_offenses(node, left, right, MSG, start_ok: start_ok,
                                                   end_ok: end_ok)
          else
            compact_offenses(node, left, right, start_ok, end_ok)
          end
        end

        def next_to_comment?(node, token)
          tokens(node)[index_for(node, token) + 1].comment?
        end

        def compact_offenses(node, left, right, start_ok, end_ok)
          if qualifies_for_compact?(node, left, side: :left)
            compact_offense(node, left, side: :left)
          elsif !multi_dimensional_array?(node, left, side: :left)
            space_offenses(node, left, nil, MSG, start_ok: start_ok,
                                                 end_ok: true)
          end
          if qualifies_for_compact?(node, right)
            compact_offense(node, right)
          elsif !multi_dimensional_array?(node, right)
            space_offenses(node, nil, right, MSG, start_ok: true,
                                                  end_ok: end_ok)
          end
        end

        def qualifies_for_compact?(node, token, side: :right)
          if side == :right
            multi_dimensional_array?(node, token) &&
              !next_to_bracket?(token)
          else
            multi_dimensional_array?(node, token, side: :left) &&
              !next_to_bracket?(token, side: :left)
          end
        end

        def multi_dimensional_array?(node, token, side: :right)
          i = index_for(node, token)
          if side == :right
            right_bracket?(tokens(node)[i - 1])
          else
            left_bracket?(tokens(node)[i + 1])
          end
        end

        def right_bracket?(token)
          token.type == :tRBRACK
        end

        def left_bracket?(token)
          token.type == :tLBRACK
        end

        def next_to_bracket?(token, side: :right)
          line_index, col = line_and_column_for(token)
          line = processed_source.lines[line_index]
          side == :right ? line[col] == ']' : line[col + 2] == '['
        end

        def compact_offense(node, token, side: :right)
          if side == :right
            space_offense(node, token, :left, MSG, NO_SPACE_COMMAND)
          else
            space_offense(node, token, :right, MSG, NO_SPACE_COMMAND)
          end
        end

        def compact_corrections(corrector, node, left, right)
          if qualifies_for_compact?(node, left, side: :left)
            range = side_space_range(range: left.pos, side: :right)
            corrector.remove(range)
          elsif !space_after?(left)
            corrector.insert_after(left.pos, ' ')
          end
          if qualifies_for_compact?(node, right)
            range = side_space_range(range: right.pos, side: :left)
            corrector.remove(range)
          elsif !space_before?(right)
            corrector.insert_before(right.pos, ' ')
          end
        end
      end
    end
  end
end
