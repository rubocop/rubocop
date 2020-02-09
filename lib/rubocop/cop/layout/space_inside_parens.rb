# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for spaces inside ordinary round parentheses.
      #
      # @example EnforcedStyle: no_space (default)
      #   # The `no_space` style enforces that parentheses do not have spaces.
      #
      #   # bad
      #   f( 3)
      #   g = (a + 3 )
      #
      #   # good
      #   f(3)
      #   g = (a + 3)
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that parentheses have a space at the
      #   # beginning and end.
      #   # Note: Empty parentheses should not have spaces.
      #
      #   # bad
      #   f(3)
      #   g = (a + 3)
      #   y( )
      #
      #   # good
      #   f( 3 )
      #   g = ( a + 3 )
      #   y()
      #
      # @example EnforcedStyle: space_after_colon
      #   # The `space_after_colon` style enforces that parentheses do not have
      #   # spaces, except after keyword parameters with no value.
      #
      #   # bad
      #   f( 3)
      #   g = (a + 3 )
      #   def y(x:); end
      #   y(x: 1 )
      #
      #   # good
      #   f(3)
      #   g = (a + 3)
      #   def y(x: ); end
      #   y(x: 1)
      #
      class SpaceInsideParens < Cop
        include RangeHelp
        include ConfigurableEnforcedStyle
        include KwargNode

        MSGS = {
          no_space: 'Space inside parentheses detected.',
          space: 'No space inside parentheses detected.',
          space_after_colon: 'No space after colon inside parentheses.'
        }.freeze

        def investigate(processed_source)
          @processed_source = processed_source

          each_violation(processed_source.tokens) do |token1, token2|
            range = range_for(token1, token2)
            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          lambda do |corrector|
            if style == :space || style == :space_after_colon && @kwarg
              corrector.insert_before(range, ' ')
            else
              corrector.remove(range)
            end
          end
        end

        private

        def each_violation(tokens)
          tokens.each_cons(2) do |token1, token2|
            # If the second token is a comment, that means that a line break
            # follows, and that the rules for space inside don't apply.
            next if token2.comment?
            next unless parens?(token1, token2)
            next unless same_line?(token1, token2)
            next unless violation?(token1)

            yield token1, token2
          end
        end

        def parens?(token1, token2)
          token1.left_parens? || token2.right_parens?
        end

        def same_line?(token1, token2)
          token1.line == token2.line
        end

        def violation?(token1)
          if style == :space
            !token1.space_after?
          elsif style == :no_space
            token1.space_after?
          else # :space_after_colon
            @kwarg = kwarg?(token1)
            @kwarg ? !token1.space_after? : token1.space_after?
          end
        end

        def range_for(token1, token2)
          if style == :space
            space_range_for(token1, token2)
          elsif style == :no_space || style == :space_after_colon && !@kwarg
            range_between(token1.end_pos, token2.begin_pos)
          else # :space_after_colon && @kwarg
            range_between(token2.begin_pos, token2.end_pos)
          end
        end

        def space_range_for(token1, token2)
          if token1.left_parens?
            range_between(token2.begin_pos, token2.begin_pos + 1)
          elsif token2.right_parens?
            range_between(token2.begin_pos, token2.end_pos)
          end
        end

        def message(*)
          if style == :space || style == :no_space
            MSGS[style]
          else # :space_after_colon
            @kwarg ? MSGS[:space_after_colon] : MSGS[:no_space]
          end
        end
      end
    end
  end
end
