# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for comma (,) preceded by space.
      class SpaceBeforeComma < Cop
        include SpaceBeforePunctuation

        def kind(token)
          'comma' if token.type == :tCOMMA
        end
      end
    end
  end
end
