# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for semicolon (;) not followed by some kind of space.
      #
      # @example
      #   # bad
      #   x = 1;y = 2
      #
      #   # good
      #   x = 1; y = 2
      #
      # @api private
      class SpaceAfterSemicolon < Base
        include SpaceAfterPunctuation
        extend AutoCorrector

        def space_style_before_rcurly
          cfg = config.for_cop('Layout/SpaceInsideBlockBraces')
          cfg['EnforcedStyle'] || 'space'
        end

        def kind(token)
          'semicolon' if token.semicolon?
        end
      end
    end
  end
end
