# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # This cop enforces the use of `same_line?` instead of location line comparison for equality.
      #
      # @example
      #   # bad
      #   node.loc.line == node.parent.loc.line
      #
      #   # good
      #   same_line?(node, node.parent)
      #
      class LocationLineEqualityComparison < Base
        extend AutoCorrector

        MSG = 'Use `%<preferred>s`.'

        # @!method location_line_equality_comparison?(node)
        def_node_matcher :location_line_equality_comparison?, <<~PATTERN
          (send
            (send (send _ :loc) :line) :==
            (send (send _ :loc) :line))
        PATTERN

        def on_send(node)
          return unless location_line_equality_comparison?(node)

          lhs, _op, rhs = *node

          lhs_receiver = lhs.receiver.receiver.source
          rhs_receiver = rhs.receiver.receiver.source
          preferred = "same_line?(#{lhs_receiver}, #{rhs_receiver})"

          add_offense(node, message: format(MSG, preferred: preferred)) do |corrector|
            corrector.replace(node, preferred)
          end
        end
      end
    end
  end
end
