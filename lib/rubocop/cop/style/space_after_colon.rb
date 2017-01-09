# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for colon (:) not followed by some kind of space.
      # N.B. this cop does not handle spaces after a ternary operator, which are
      # instead handled by Style/SpaceAroundOperators.
      class SpaceAfterColon < Cop
        MSG = 'Space missing after colon.'.freeze

        def on_pair(node)
          return unless node.colon?

          colon = node.loc.operator

          add_offense(colon, colon) unless followed_by_space?(colon)
        end

        def on_kwoptarg(node)
          # We have no direct reference to the colon source range following an
          # optional keyword argument's name, so must construct one.
          colon = node.loc.name.end.resize(1)

          add_offense(colon, colon) unless followed_by_space?(colon)
        end

        private

        def followed_by_space?(colon)
          colon.source_buffer.source[colon.end_pos] =~ /\s/
        end

        def autocorrect(range)
          ->(corrector) { corrector.insert_after(range, ' ') }
        end
      end
    end
  end
end
