# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that brackets used for array literals have or don't have
      # surrounding space depending on configuration.
      #
      # @example EnforcedStyle: no_space (default)
      #   # The `no_space` style enforces that array literals have
      #   # no surrounding space.
      #
      #   # bad
      #   array = [ a, b, c, d ]
      #
      #   # good
      #   array = [a, b, c, d]
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
      # @example EnforcedStyle: compact
      #   # The `compact` style normally requires a space inside
      #   # array brackets, with the exception that successive left
      #   # or right brackets are collapsed together in nested arrays.
      #
      #   # bad
      #   array = [ a, [ b, c ] ]
      #   array = [
      #     [ a ],
      #     [ b, c ]
      #   ]
      #
      #   # good
      #   array = [ a, [ b, c ]]
      #   array = [[ a ],
      #     [ b, c ]]
      #
      # @example EnforcedStyleForEmptyBrackets: no_space (default)
      #   # The `no_space` EnforcedStyleForEmptyBrackets style enforces that
      #   # empty array brackets do not contain spaces.
      #
      #   # bad
      #   foo = [ ]
      #   bar = [     ]
      #
      #   # good
      #   foo = []
      #   bar = []
      #
      # @example EnforcedStyleForEmptyBrackets: space
      #   # The `space` EnforcedStyleForEmptyBrackets style enforces that
      #   # empty array brackets contain exactly one space.
      #
      #   # bad
      #   foo = []
      #   bar = [    ]
      #
      #   # good
      #   foo = [ ]
      #   bar = [ ]
      #
      class SpaceInsideArrayLiteralBrackets < Base
        include SurroundingSpace
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG = '%<command>s space inside array brackets.'
        EMPTY_MSG = '%<command>s space inside empty array brackets.'

        def on_array(node)
          return unless node.square_brackets?

          left, right = array_brackets(node)
          return empty_offenses(node, left, right, EMPTY_MSG) if empty_brackets?(left, right)

          start_ok = next_to_newline?(node, left)
          end_ok = node.single_line? ? false : end_has_own_line?(right)

          issue_offenses(node, left, right, start_ok, end_ok)
        end

        private

        def autocorrect(corrector, node)
          left, right = array_brackets(node)

          if empty_brackets?(left, right)
            SpaceCorrector.empty_corrections(processed_source, corrector, empty_config, left, right)
          elsif style == :no_space
            SpaceCorrector.remove_space(processed_source, corrector, left, right)
          elsif style == :space
            SpaceCorrector.add_space(processed_source, corrector, left, right)
          else
            compact_corrections(corrector, node, left, right)
          end
        end

        def array_brackets(node)
          [left_array_bracket(node), right_array_bracket(node)]
        end

        def left_array_bracket(node)
          processed_source.tokens_within(node).find(&:left_array_bracket?)
        end

        def right_array_bracket(node)
          processed_source.tokens_within(node).reverse.find(&:right_bracket?)
        end

        def empty_config
          cop_config['EnforcedStyleForEmptyBrackets']
        end

        def next_to_newline?(node, token)
          processed_source.tokens_within(node)[index_for(node, token) + 1].line != token.line
        end

        def end_has_own_line?(token)
          line, col = line_and_column_for(token)
          return true if col == -1

          !/\S/.match?(processed_source.lines[line][0..col])
        end

        def index_for(node, token)
          processed_source.tokens_within(node).index(token)
        end

        def line_and_column_for(token)
          [token.line - 1, token.column - 1]
        end

        def issue_offenses(node, left, right, start_ok, end_ok)
          case style
          when :no_space
            start_ok = next_to_comment?(node, left)
            no_space_offenses(node, left, right, MSG, start_ok: start_ok, end_ok: end_ok)
          when :space
            space_offenses(node, left, right, MSG, start_ok: start_ok, end_ok: end_ok)
          else
            compact_offenses(node, left, right, start_ok, end_ok)
          end
        end

        def next_to_comment?(node, token)
          processed_source.tokens_within(node)[index_for(node, token) + 1].comment?
        end

        def compact_offenses(node, left, right, start_ok, end_ok)
          if qualifies_for_compact?(node, left, side: :left)
            compact_offense(node, left, side: :left)
          elsif !multi_dimensional_array?(node, left, side: :left)
            space_offenses(node, left, nil, MSG, start_ok: start_ok, end_ok: true)
          end
          if qualifies_for_compact?(node, right)
            compact_offense(node, right)
          elsif !multi_dimensional_array?(node, right)
            space_offenses(node, nil, right, MSG, start_ok: true, end_ok: end_ok)
          end
        end

        def qualifies_for_compact?(node, token, side: :right)
          if side == :right
            multi_dimensional_array?(node, token) && !next_to_bracket?(token)
          else
            multi_dimensional_array?(node, token, side: :left) &&
              !next_to_bracket?(token, side: :left)
          end
        end

        def multi_dimensional_array?(node, token, side: :right)
          i = index_for(node, token)
          if side == :right
            processed_source.tokens_within(node)[i - 1].right_bracket?
          else
            processed_source.tokens_within(node)[i + 1].left_array_bracket?
          end
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
            compact(corrector, left, :right)
          elsif !left.space_after?
            corrector.insert_after(left.pos, ' ')
          end
          if qualifies_for_compact?(node, right)
            compact(corrector, right, :left)
          elsif !right.space_before?
            corrector.insert_before(right.pos, ' ')
          end
        end

        def compact(corrector, bracket, side)
          range = side_space_range(range: bracket.pos, side: side)
          corrector.remove(range)
        end
      end
    end
  end
end
