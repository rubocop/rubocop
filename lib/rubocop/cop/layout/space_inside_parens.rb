# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      #

      # Checks for spaces inside ordinary round parentheses.
      #
      # @example EnforcedStyle: no_space (default)
      #   # The `no_space` style enforces that parentheses do not have spaces
      #
      # @example
      #   # bad
      #   f( 3)
      #   g = (a + 3 )
      #
      #   # good
      #   f(3)
      #   g = (a + 3)
      #
      # @example EnforcedStyle: space
      #   # The `space` style enforces that parentheses have a space at the beginning and end.
      #   # Note: Empty paraentheses should not have spaces.
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
      class SpaceInsideParens < Cop
        include SurroundingSpace
        include RangeHelp

        MSG       = 'Space inside parentheses detected.'.freeze
        MSG_SPACE = 'No space inside parentheses detected.'.freeze

        def investigate(processed_source)
          @processed_source = processed_source

          if cop_config["EnforcedStyle"] == "space"
            each_missing_space(processed_source.tokens) do |range|
              add_offense(range, location: range, message: MSG_SPACE)
            end
          
          else
            each_extraneous_space(processed_source.tokens) do |range|
              add_offense(range, location: range, message: MSG)
            end
          end
        end

        def autocorrect(range)
          lambda do |corrector| 
            if cop_config["EnforcedStyle"] == "space" 
              # SpaceCorrector.add_space(processed_source, corrector, left, right)
              corrector.insert_before(range, ' ')
            else
              corrector.remove(range)
            end
          end
        end

        private

        def each_extraneous_space(tokens)
          tokens.each_cons(2) do |token1, token2|
            next unless parens?(token1, token2)

            # If the second token is a comment, that means that a line break
            # follows, and that the rules for space inside don't apply.
            next if token2.comment?
            next unless token2.line == token1.line && token1.space_after?

            yield range_between(token1.end_pos, token2.begin_pos)
          end
        end

        def each_missing_space(tokens)
          tokens.each_cons(2) do |token1, token2|
            next unless parens?(token1, token2)

            # If the second token is a comment, that means that a line break
            # follows, and that the rules for space inside don't apply.
            next if token2.comment?
            next unless token2.line == token1.line && !token1.space_after?

            next if token1.left_parens? && token2.right_parens? # Ignore empty parens. # TODO: This could be another configuration option.

            if token1.left_parens? 
              yield range_between(token2.begin_pos, token2.begin_pos + 1) 

            elsif token2.right_parens? 
              yield range_between(token2.begin_pos, token2.end_pos) 
            end
          end
        end

        def parens?(token1, token2)
          token1.left_parens? || token2.right_parens?
        end
      end
    end
  end
end
