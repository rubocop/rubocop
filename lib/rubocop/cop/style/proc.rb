# encoding: utf-8

module Rubocop
  module Cop
    module Style
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

          if block_method == TARGET
            add_offence(:convention, block_method.loc.expression, MSG)
          end

          super
        end
      end
    end
  end
end
