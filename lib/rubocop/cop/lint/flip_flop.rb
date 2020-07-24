# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop looks for uses of flip-flop operator.
      # flip-flop operator is deprecated since Ruby 2.6.0.
      #
      # @example
      #   # bad
      #   (1..20).each do |x|
      #     puts x if (x == 5) .. (x == 10)
      #   end
      #
      #   # good
      #   (1..20).each do |x|
      #     puts x if (x >= 5) && (x <= 10)
      #   end
      class FlipFlop < Base
        MSG = 'Avoid the use of flip-flop operators.'

        def on_iflipflop(node)
          add_offense(node)
        end

        def on_eflipflop(node)
          add_offense(node)
        end
      end
    end
  end
end
