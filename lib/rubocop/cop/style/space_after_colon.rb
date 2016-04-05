# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for colon (:) not followed by some kind of space.
      # N.B. this cop does not handle spaces after a ternary operator, which are
      # instead handled by Style/SpaceAroundOperators.
      class SpaceAfterColon < Cop
        include IfNode

        MSG = 'Space missing after colon.'.freeze

        def on_pair(node)
          oper = node.loc.operator
          return unless oper.is?(':') && followed_by_space?(oper)

          add_offense(oper, oper)
        end

        def followed_by_space?(colon)
          colon.source_buffer.source[colon.end_pos] =~ /\S/
        end

        def autocorrect(range)
          ->(corrector) { corrector.insert_after(range, ' ') }
        end
      end
    end
  end
end
