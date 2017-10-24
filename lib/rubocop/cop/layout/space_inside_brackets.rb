# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for spaces inside square brackets.
      # @example
      #   # bad
      #   array = [ 1, 2, 3 ]
      #
      #   # good
      #   array = [1, 2, 3]
      class SpaceInsideBrackets < Cop
        include SpaceInside

        def specifics
          [
            %i[tLBRACK tLBRACK2],
            :tRBRACK,
            'square brackets'
          ]
        end
      end
    end
  end
end
