# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for spaces inside ordinary round parentheses.
      class SpaceInsideParens < Cop
        include SpaceInside

        def specifics
          [[:tLPAREN, :tLPAREN2], :tRPAREN, 'parentheses']
        end
      end
    end
  end
end
