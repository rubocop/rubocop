# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for `rand(1)` calls.
      # Such calls always return `0`.
      #
      # @example
      #
      #   # bad
      #
      #   rand 1
      #   Kernel.rand(-1)
      #   rand 1.0
      #   rand(-1.0)
      #
      # @example
      #
      #   # good
      #
      #   0 # just use 0 instead
      class RandOne < Cop
        MSG = '`%s` always returns `0`. ' \
              'Perhaps you meant `rand(2)` or `rand`?'.freeze

        def_node_matcher :rand_one?, <<-PATTERN
          (send {(const nil :Kernel) nil} :rand {(int {-1 1}) (float {-1.0 1.0})})
        PATTERN

        def on_send(node)
          return unless rand_one?(node)

          add_offense(node, :expression, format(MSG, node.source))
        end
      end
    end
  end
end
