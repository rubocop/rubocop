# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that brackets used for array literals have or don't have
      # surrounding space depending on configuration.
      #
      # Array pattern matching is handled in the same way.
      #
      # @example EnforcedStyle: no_space (default)
      #   # The `no_space` style enforces that array literals have
      #   # no surrounding space.
      #
      #   # bad
      #   array = [ a, b, c, d ]
      #   array = [ a, [ b, c ]]
      #
      #   # good
      #   array = [a, b, c, d]
      #   array = [a, [b, c]]
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that array literals have
      #   # surrounding space.
      #
      #   # bad
      #   array = [a, b, c, d]
      #   array = [ a, [ b, c ]]
      #
      #   # good
      #   array = [ a, b, c, d ]
      #   array = [ a, [ b, c ] ]
      #
      # @example EnforcedStyle: compact
      #   # The `compact` style normally requires a space inside
      #   # array brackets, with the exception that successive left
      #   # or right brackets are collapsed together in nested arrays.
      #
      #   # bad
      #   array = [a, b, c, d]
      #   array = [ a, [ b, c ] ]
      #   array = [
      #     [ a ],
      #     [ b, c ]
      #   ]
      #
      #   # good
      #   array = [ a, b, c, d ]
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
          return if node.array_type? && !node.square_brackets?

          node = find_node_with_brackets(node)
          tokens, left, right = array_brackets(node)
          return unless left && right

          if empty_brackets?(left, right, tokens: tokens)
            return empty_offenses(node, left, right, EMPTY_MSG)
          end

          start_ok = next_to_newline?(tokens, left)
          end_ok = node.single_line? ? false : end_has_own_line?(right)

          issue_offenses(node, tokens, left, right, start_ok, end_ok)
        end
        alias on_array_pattern on_array

        private

        def find_node_with_brackets(node)
          node.ancestors.find(&:const_pattern_type?) || node
        end

        def autocorrect(corrector, node)
          tokens, left, right = array_brackets(node)

          if empty_brackets?(left, right, tokens: tokens)
            SpaceCorrector.empty_corrections(processed_source, corrector, empty_config, left, right)
          elsif style == :no_space
            SpaceCorrector.remove_space(processed_source, corrector, left, right)
          elsif style == :space
            SpaceCorrector.add_space(processed_source, corrector, left, right)
          else
            compact_corrections(corrector, tokens, left, right)
          end
        end

        def array_brackets(node)
          tokens = processed_source.tokens_within(node)

          left = tokens.find(&:left_bracket?)
          right = tokens.reverse_each.find(&:right_bracket?)

          [tokens, left, right]
        end

        def empty_config
          cop_config['EnforcedStyleForEmptyBrackets']
        end

        def next_to_newline?(tokens, token)
          tokens[index_for(tokens, token) + 1].line != token.line
        end

        def end_has_own_line?(token)
          line, col = line_and_column_for(token)
          return true if col == -1

          !/\S/.match?(processed_source.lines[line][0..col])
        end

        def index_for(tokens, token)
          tokens.index(token)
        end

        def line_and_column_for(token)
          [token.line - 1, token.column - 1]
        end

        # rubocop:disable Metrics/ParameterLists
        def issue_offenses(node, tokens, left, right, start_ok, end_ok)
          case style
          when :no_space
            start_ok = next_to_comment?(tokens, left)
            no_space_offenses(node, left, right, MSG, start_ok: start_ok, end_ok: end_ok)
          when :space
            space_offenses(node, left, right, MSG, start_ok: start_ok, end_ok: end_ok)
          else
            compact_offenses(node, tokens, left, right, start_ok, end_ok)
          end
        end
        # rubocop:enable Metrics/ParameterLists

        def next_to_comment?(tokens, token)
          tokens[index_for(tokens, token) + 1].comment?
        end

        # rubocop:disable Metrics/ParameterLists
        def compact_offenses(node, tokens, left, right, start_ok, end_ok)
          if qualifies_for_compact?(tokens, left, side: :left)
            compact_offense(node, left, side: :left)
          elsif !multi_dimensional_array?(tokens, left, side: :left)
            space_offenses(node, left, nil, MSG, start_ok: start_ok, end_ok: true)
          end

          if qualifies_for_compact?(tokens, right)
            compact_offense(node, right)
          elsif !multi_dimensional_array?(tokens, right)
            space_offenses(node, nil, right, MSG, start_ok: true, end_ok: end_ok)
          end
        end
        # rubocop:enable Metrics/ParameterLists

        def qualifies_for_compact?(tokens, token, side: :right)
          if side == :right
            multi_dimensional_array?(tokens, token) && token.space_before?
          else
            multi_dimensional_array?(tokens, token, side: :left) && token.space_after?
          end
        end

        def multi_dimensional_array?(tokens, token, side: :right)
          offset = side == :right ? -1 : +1
          i = index_for(tokens, token) + offset
          i += offset while tokens[i].new_line?
          if side == :right
            tokens[i].right_bracket?
          else
            tokens[i].left_bracket?
          end
        end

        def compact_offense(node, token, side: :right)
          if side == :right
            space_offense(node, token, :left, MSG, NO_SPACE_COMMAND)
          else
            space_offense(node, token, :right, MSG, NO_SPACE_COMMAND)
          end
        end

        def compact_corrections(corrector, tokens, left, right)
          if multi_dimensional_array?(tokens, left, side: :left)
            compact(corrector, left, :right)
          elsif !left.space_after?
            corrector.insert_after(left.pos, ' ')
          end

          if multi_dimensional_array?(tokens, right)
            compact(corrector, right, :left)
          elsif !right.space_before?
            corrector.insert_before(right.pos, ' ')
          end
        end

        def compact(corrector, bracket, side)
          range = side_space_range(range: bracket.pos, side: side, include_newlines: true)
          corrector.remove(range)
        end
      end
    end
  end
end
