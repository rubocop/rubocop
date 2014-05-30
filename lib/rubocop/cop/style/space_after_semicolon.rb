# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for semicolon (;) not followed by some kind of space.
      class SpaceAfterSemicolon < Cop
        include SpaceAfterPunctuation

        def kind(token)
          'semicolon' if token.type == :tSEMI
        end
      end
    end
  end
end
