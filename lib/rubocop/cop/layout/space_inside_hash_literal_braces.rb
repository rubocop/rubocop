# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that braces used for hash literals have or don't have
      # surrounding space depending on configuration.
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that hash literals have
      #   # surrounding space.
      #
      #   # bad
      #   h = {a: 1, b: 2}
      #
      #   # good
      #   h = { a: 1, b: 2 }
      #
      # @example EnforcedStyle: no_space
      #   # The `no_space` style enforces that hash literals have
      #   # no surrounding space.
      #
      #   # bad
      #   h = { a: 1, b: 2 }
      #
      #   # good
      #   h = {a: 1, b: 2}
      #
      # @example EnforcedStyle: compact
      #   # The `compact` style normally requires a space inside
      #   # hash braces, with the exception that successive left
      #   # braces or right braces are collapsed together in nested hashes.
      #
      #   # bad
      #   h = { a: { b: 2 } }
      #
      #   # good
      #   h = { a: { b: 2 }}
      class SpaceInsideHashLiteralBraces < Cop
        include SurroundingSpace
        include ConfigurableEnforcedStyle

        MSG = 'Space inside %s.'.freeze

        def on_hash(node)
          tokens = processed_source.tokens

          hash_literal_with_braces(node) do |begin_index, end_index|
            check(tokens[begin_index], tokens[begin_index + 1])
            return if begin_index == end_index - 1

            check(tokens[end_index - 1], tokens[end_index])
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            # It is possible that BracesAroundHashParameters will remove the
            # braces while this cop inserts spaces. This can lead to unwanted
            # changes to the inspected code. If we replace the brace with a
            # brace plus space (rather than just inserting a space), then any
            # removal of the same brace will give us a clobbering error. This
            # in turn will make RuboCop fall back on cop-by-cop
            # auto-correction.  Problem solved.
            case range.source
            when /\s/ then corrector.remove(range)
            when '{' then corrector.replace(range, '{ ')
            else corrector.replace(range, ' }')
            end
          end
        end

        private

        def hash_literal_with_braces(node)
          tokens = processed_source.tokens
          begin_index = index_of_first_token(node)
          return unless left_brace?(tokens[begin_index])

          end_index = index_of_last_token(node)
          return unless right_brace?(tokens[end_index])

          yield begin_index, end_index
        end

        def left_brace?(token)
          token.type == :tLBRACE
        end

        def right_brace?(token)
          token.type == :tRCURLY
        end

        def check(t1, t2)
          # No offense if line break inside.
          return if t1.line < t2.line
          return if t2.type == :tCOMMENT # Also indicates there's a line break.

          is_empty_braces = left_brace?(t1) && right_brace?(t2)
          expect_space    = expect_space?(t1, t2)

          if offense?(t1, expect_space)
            incorrect_style_detected(t1, t2, expect_space, is_empty_braces)
          else
            correct_style_detected
          end
        end

        def expect_space?(t1, t2)
          is_same_braces  = t1.type == t2.type
          is_empty_braces = left_brace?(t1) && right_brace?(t2)

          if is_same_braces && style == :compact
            false
          elsif is_empty_braces
            cop_config['EnforcedStyleForEmptyBraces'] != 'no_space'
          else
            style != :no_space
          end
        end

        def incorrect_style_detected(t1, t2, expect_space, is_empty_braces)
          brace = (t1.text == '{' ? t1 : t2).pos
          range = expect_space ? brace : space_range(brace)
          add_offense(
            range,
            location: range,
            message: message(brace, is_empty_braces, expect_space)
          ) do
            style = expect_space ? :no_space : :space
            ambiguous_or_unexpected_style_detected(style, t1.text == t2.text)
          end
        end

        def ambiguous_or_unexpected_style_detected(style, is_match)
          if is_match
            ambiguous_style_detected(style, :compact)
          else
            unexpected_style_detected(style)
          end
        end

        def offense?(t1, expect_space)
          has_space = space_after?(t1)
          expect_space ? !has_space : has_space
        end

        def message(brace, is_empty_braces, expect_space)
          inside_what = if is_empty_braces
                          'empty hash literal braces'
                        else
                          brace.source
                        end
          problem = expect_space ? 'missing' : 'detected'
          format(MSG, "#{inside_what} #{problem}")
        end

        def space_range(token_range)
          if token_range.source == '{'
            range_of_space_to_the_right(token_range)
          else
            range_of_space_to_the_left(token_range)
          end
        end

        def range_of_space_to_the_right(range)
          src = range.source_buffer.source
          end_pos = range.end_pos
          end_pos += 1 while src[end_pos] =~ /[ \t]/

          range_between(range.begin_pos + 1, end_pos)
        end

        def range_of_space_to_the_left(range)
          src = range.source_buffer.source
          begin_pos = range.begin_pos
          begin_pos -= 1 while src[begin_pos - 1] =~ /[ \t]/

          range_between(begin_pos, range.end_pos - 1)
        end
      end
    end
  end
end
