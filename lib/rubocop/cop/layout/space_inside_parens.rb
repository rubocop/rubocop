# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for spaces inside ordinary round parentheses.
      #
      # @example
      #   # bad
      #   f( 3)
      #   g = (a + 3 )
      #
      #   # good
      #   f(3)
      #   g = (a + 3)
      class SpaceInsideParens < Cop
        include SurroundingSpace

        MSG = 'Space inside parentheses detected.'.freeze

        def investigate(processed_source)
          @processed_source = processed_source
          each_extraneous_space(processed_source.tokens) do |range|
            add_offense(range, location: range)
          end
        end

        def autocorrect(range)
          ->(corrector) { corrector.remove(range) }
        end

        private

        def each_extraneous_space(tokens)
          tokens.each_cons(2) do |t1, t2|
            next unless parens?(t1, t2)

            # If the second token is a comment, that means that a line break
            # follows, and that the rules for space inside don't apply.
            next if t2.comment?
            next unless t2.line == t1.line && t1.space_after?

            yield range_between(t1.end_pos, t2.begin_pos)
          end
        end

        def parens?(t1, t2)
          t1.left_parens? || t2.right_parens?
        end
      end
    end
  end
end
