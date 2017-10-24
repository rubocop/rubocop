# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for comma (,) preceded by space.
      #
      # @example
      #   # bad
      #   [1 , 2 , 3]
      #
      #   # good
      #   [1, 2, 3]
      class SpaceBeforeComma < Cop
        include SpaceBeforePunctuation

        def kind(token)
          'comma' if token.type == :tCOMMA
        end
      end
    end
  end
end
