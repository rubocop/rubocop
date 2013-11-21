# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for spaces inside ordinary round parentheses.
      class SpaceInsideParens < Cop
        include SpaceInside

        def specifics
          [:tLPAREN2, :tRPAREN, 'parentheses']
        end
      end
    end
  end
end
