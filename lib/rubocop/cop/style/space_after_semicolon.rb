# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for semicolon (;) not follwed by some kind of space.
      class SpaceAfterSemicolon < Cop
        include SpaceAfterPunctuation

        def kind(token)
          'semicolon' if token.type == :tSEMI
        end
      end
    end
  end
end
