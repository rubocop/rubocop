# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # In math and Python, we can use `x < y < z` style comparison to compare
      # multiple value. However, we can't use the comparison in Ruby. However,
      # the comparison is not syntax error. This cop checks the bad usage of
      # comparison operators.
      #
      # @example
      #
      #   # bad
      #
      #   x < y < z
      #   10 <= x <= 20
      #
      # @example
      #
      #   # good
      #
      #   x < y && y < z
      #   10 <= x && x <= 20
      class MultipleComparison < Cop
        MSG = 'Use the `&&` operator to compare multiple values.'

        def_node_matcher :multiple_compare?, <<~PATTERN
          (send (send _ {:< :> :<= :>=} $_) {:< :> :<= :>=} _)
        PATTERN

        def on_send(node)
          return unless multiple_compare?(node)

          add_offense(node)
        end

        def autocorrect(node)
          center = multiple_compare?(node)
          new_center = "#{center.source} && #{center.source}"

          lambda do |corrector|
            corrector.replace(center.source_range, new_center)
          end
        end
      end
    end
  end
end
