# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of flip flop operator
      class FlipFlop < Cop
        MSG = 'Avoid the use of flip flop operators.'.freeze

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
