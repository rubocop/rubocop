# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the use of the round method.
      #
      # @example
      #
      #   @bad
      #   6.75.round
      #   6.75.round(0)
      #
      #   @good
      #   6.75.floor
      #   6.75.ceil
      #   6.75.round(2)
      #
      class Round < Cop
        MSG = 'Prefer `Float#floor` or `Float#ceil` over `Float#round`.'.freeze

        def_node_matcher :rounding?, '{(send _ :round (int 0)) (send _ :round)}'

        def on_send(node)
          rounding?(node) do
            add_offense(node, :selector)
          end
        end
      end
    end
  end
end
