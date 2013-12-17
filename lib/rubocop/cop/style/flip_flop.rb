# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of flip flop operator
      class FlipFlop < Cop
        MSG = 'Avoid the use of flip flop operators.'

        def on_iflipflop(node)
          add_offence(node, :expression)
        end

        def on_eflipflop(node)
          add_offence(node, :expression)
        end
      end
    end
  end
end
