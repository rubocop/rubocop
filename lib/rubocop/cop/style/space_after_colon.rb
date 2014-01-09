# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for colon (:) not follwed by some kind of space.
      class SpaceAfterColon < Cop
        include IfNode

        MSG = 'Space missing after colon.'

        def on_pair(node)
          oper = node.loc.operator
          if oper.is?(':') && oper.source_buffer.source[oper.end_pos] =~ /\S/
            add_offence(oper, oper)
          end
        end

        def on_if(node)
          if ternary_op?(node)
            colon = node.loc.colon
            if colon.source_buffer.source[colon.end_pos] =~ /\S/
              add_offence(colon, colon)
            end
          end
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
