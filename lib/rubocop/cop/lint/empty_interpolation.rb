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
        MSG = 'Empty interpolation detected.'

        def on_dstr(node)
          node.each_child_node(:begin) do |begin_node|
            add_offense(begin_node) if begin_node.children.empty?
          end
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
