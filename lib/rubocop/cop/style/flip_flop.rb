# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop looks for uses of flip flop operator
      class FlipFlop < Cop
        MSG = 'Avoid the use of flip flop operators.'
        private_constant :MSG

        def on_iflipflop(node)
          add_offense(node, :expression, MSG)
        end

        def on_eflipflop(node)
          add_offense(node, :expression, MSG)
        end
      end
    end
  end
end
