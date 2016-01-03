# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for spaces inside square brackets.
      class SpaceInsideBrackets < Cop
        include SpaceInside

        def specifics
          [
            [:tLBRACK, :tLBRACK2],
            :tRBRACK,
            'square brackets'
          ]
        end
      end
    end
  end
end
