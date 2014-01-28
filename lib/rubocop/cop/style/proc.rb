# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cops checks for uses of Proc.new where Kernel#proc
      # would be more appropriate.
      class Proc < Cop
        MSG = 'Use proc instead of Proc.new.'

        TARGET = s(:send, s(:const, nil, :Proc), :new)

        def on_block(node)
          # We're looking for
          # (block
          #   (send
          #     (const nil :Proc) :new)
          #   ...)
          block_method, = *node

          add_offence(block_method, :expression) if block_method == TARGET
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.replace(node.loc.expression, 'proc')
          end
        end
      end
    end
  end
end
