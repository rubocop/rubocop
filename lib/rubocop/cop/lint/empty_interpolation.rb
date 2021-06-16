# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for empty interpolation.
      #
      # @example
      #
      #   # bad
      #
      #   "result is #{}"
      #
      # @example
      #
      #   # good
      #
      #   "result is #{some_result}"
      class EmptyInterpolation < Base
        include Interpolation
        extend AutoCorrector

        MSG = 'Empty interpolation detected.'

        def on_interpolation(begin_node)
          return unless begin_node.children.empty?

          add_offense(begin_node) { |corrector| corrector.remove(begin_node.loc.expression) }
        end
      end
    end
  end
end
