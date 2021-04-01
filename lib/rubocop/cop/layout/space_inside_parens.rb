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
      #   f( )
      #
      #   # good
      #   f(3)
      #   g = (a + 3)
      #   f()
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
      class SpaceInsideParens < Base
        include SurroundingSpace
        include RangeHelp
        include ConfigurableEnforcedStyle
        extend AutoCorrector

        MSG       = 'Space inside parentheses detected.'
        MSG_SPACE = 'No space inside parentheses detected.'

        def on_new_investigation
          @processed_source = processed_source

          if style == :space
            process_with_space_style(processed_source)
          else
            each_extraneous_space(processed_source.tokens) do |range|
              add_offense(range) do |corrector|
                corrector.remove(range)
              end
            end
          end
        end

        private

        def process_with_space_style(processed_source)
          processed_source.tokens.each_cons(2) do |token1, token2|
            each_extraneous_space_in_empty_parens(token1, token2) do |range|
              add_offense(range) do |corrector|
                corrector.remove(range)
              end
            end
            each_missing_space(token1, token2) do |range|
              add_offense(range, message: MSG_SPACE) do |corrector|
                corrector.insert_before(range, ' ')
              end
            end
          end
        end

        def each_extraneous_space(tokens)
          tokens.each_cons(2) do |token1, token2|
            next unless parens?(token1, token2)

            # If the second token is a comment, that means that a line break
            # follows, and that the rules for space inside don't apply.
            next if token2.comment?
            next unless same_line?(token1, token2) && token1.space_after?

            yield range_between(token1.end_pos, token2.begin_pos)
          end
        end

        def each_extraneous_space_in_empty_parens(token1, token2)
          return unless token1.left_parens? && token2.right_parens?

          return if range_between(token1.begin_pos, token2.end_pos).source == '()'

          yield range_between(token1.end_pos, token2.begin_pos)
        end

        def each_missing_space(token1, token2)
          return if can_be_ignored?(token1, token2)

          if token1.left_parens?
            yield range_between(token2.begin_pos, token2.begin_pos + 1)
          elsif token2.right_parens?
            yield range_between(token2.begin_pos, token2.end_pos)
          end
        end

        def same_line?(token1, token2)
          token1.line == token2.line
        end

        def parens?(token1, token2)
          token1.left_parens? || token2.right_parens?
        end

        def can_be_ignored?(token1, token2)
          return true unless parens?(token1, token2)

          # Ignore empty parentheses.
          return true if range_between(token1.begin_pos, token2.end_pos).source == '()'

          # If the second token is a comment, that means that a line break
          # follows, and that the rules for space inside don't apply.
          return true if token2.comment?

          return true unless same_line?(token1, token2) && !token1.space_after?
        end
      end
    end
  end
end
