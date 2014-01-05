# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for colon (:) not follwed by some kind of space.
      class SpaceAfterColon < Cop
        include SpaceAfterPunctuation

        # The colon following a label will not appear in the token
        # array. Instad we get a tLABEL token, whose length we use to
        # calculate where we expect a space.
        def offset(token)
          case token.type
          when :tLABEL then token.text.length + 1
          when :tCOLON then 1
          end
        end

        def kind(token)
          case token.type
          when :tLABEL, :tCOLON then 'colon'
          end
        end
      end
    end
  end
end
