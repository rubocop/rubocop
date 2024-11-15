# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Enforces the use of `node.operator_keyword?` instead of `node.and_type? || node.or_type?`.
      #
      # @example
      #   # bad
      #   node.and_type? || node.or_type?
      #   node.or_type? || node.and_type?
      #
      #   # good
      #   node.operator_keyword?
      #
      class OperatorKeyword < Base
        extend AutoCorrector

        MSG = 'Use `%<prefer>s`.'

        # @!method and_or_type(node)
        def_node_matcher :and_or_type, <<~PATTERN
          {
            (or $(send _node :and_type?) $(send _node :or_type?))
            (or $(send _node :or_type?) $(send _node :and_type?))
            (or
              (or _ $(send _node :and_type?)) $(send _node :or_type?))
            (or
              (or _ $(send _node :or_type?)) $(send _node :and_type?))
          }
        PATTERN

        def on_or(node)
          return unless (lhs, rhs = and_or_type(node))

          offense = lhs.receiver.source_range.join(rhs.source_range.end)
          prefer = "#{lhs.receiver.source}.operator_keyword?"

          add_offense(offense, message: format(MSG, prefer: prefer)) do |corrector|
            corrector.replace(offense, prefer)
          end
        end
      end
    end
  end
end
