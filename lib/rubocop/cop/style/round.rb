# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the use of the round method.
      class Round < Cop
        MSG = 'Prefer `Float#floor` or `Float#ceil` over `Float#round`.'.freeze

        def_node_matcher :rounding?, '(send _ :round ...)'

        def on_send(node)
          rounding?(node) do
            add_offense(node, :selector)
          end
        end
      end
    end
  end
end
