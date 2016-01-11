# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for colon (:) not followed by some kind of space.
      class SpaceAfterColon < Cop
        include IfNode

        MSG = 'Space missing after colon.'.freeze

        def on_pair(node)
          oper = node.loc.operator
          return unless oper.is?(':') && followed_by_space?(oper)

          add_offense(oper, oper)
        end

        def on_if(node)
          return unless ternary_op?(node)

          colon = node.loc.colon
          return unless followed_by_space?(colon)

          add_offense(colon, colon)
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
