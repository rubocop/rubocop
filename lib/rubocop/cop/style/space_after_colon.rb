# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Checks for colon (:) not followed by some kind of space.
      class SpaceAfterColon < Cop
        include IfNode

        MSG = 'Space missing after colon.'

        def on_pair(node)
          oper = node.loc.operator
          return unless oper.is?(':') &&
            oper.source_buffer.source[oper.end_pos] =~ /\S/

          add_offense(oper, oper)
        end

        def on_if(node)
          return unless ternary_op?(node)
          colon = node.loc.colon
          return unless colon.source_buffer.source[colon.end_pos] =~ /\S/

          add_offense(colon, colon)
        end

        def autocorrect(range)
          @corrections << lambda do |corrector|
            corrector.insert_after(range, ' ')
          end
        end
      end
    end
  end
end
