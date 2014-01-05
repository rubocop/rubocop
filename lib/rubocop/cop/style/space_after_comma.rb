# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for comma (,) not follwed by some kind of space.
      class SpaceAfterComma < Cop
        include SpaceAfterPunctuation

        def kind(token)
          'comma' if token.type == :tCOMMA
        end
      end
    end
  end
end
