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
      class EmptyInterpolation < Cop
        include Interpolation

        MSG = 'Empty interpolation detected.'

        def on_interpolation(begin_node)
          add_offense(begin_node) if begin_node.children.empty?
        end

        def autocorrect(node)
          lambda do |collector|
            collector.remove(node.loc.expression)
          end
        end
      end
    end
  end
end
