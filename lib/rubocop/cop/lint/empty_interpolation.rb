# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for empty interpolation.
      #
      # @example
      #
      #   # bad
      #   "result is #{}"
      #
      #   # good
      #   "result is #{some_result}"
      class EmptyInterpolation < Base
        include Interpolation
        extend AutoCorrector

        MSG = 'Empty interpolation detected.'

        def on_interpolation(begin_node)
          node_children = begin_node.children.dup
          node_children.delete_if { |e| e.nil_type? || (e.basic_literal? && e.str_content&.empty?) }
          return unless node_children.empty?

          add_offense(begin_node) { |corrector| corrector.remove(begin_node) }
        end
      end
    end
  end
end
