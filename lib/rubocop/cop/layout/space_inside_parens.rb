# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for spaces inside ordinary round parentheses.
      class SpaceInsideParens < Cop
        include SpaceInside

        def specifics
          [%i[tLPAREN tLPAREN2], :tRPAREN, 'parentheses']
        end
      end
    end
  end
end
