# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for comma (,) not followed by some kind of space.
      class SpaceAfterComma < Cop
        include SpaceAfterPunctuation

        def kind(token)
          'comma' if token.type == :tCOMMA
        end
      end
    end
  end
end
