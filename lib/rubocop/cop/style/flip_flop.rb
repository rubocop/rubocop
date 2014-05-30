# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of flip flop operator
      class FlipFlop < Cop
        MSG = 'Avoid the use of flip flop operators.'

        def on_iflipflop(node)
          add_offense(node, :expression)
        end

        def on_eflipflop(node)
          add_offense(node, :expression)
        end
      end
    end
  end
end
