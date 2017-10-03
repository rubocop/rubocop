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
        include SpaceInside

        def specifics
          [%i[tLPAREN tLPAREN2], :tRPAREN, 'parentheses']
        end
      end
    end
  end
end
