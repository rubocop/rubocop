# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for space between the name of a called method and a left
      # parenthesis.
      #
      # @example
      #
      #   # bad
      #
      #   puts (x + y)
      #
      # @example
      #
      #   # good
      #
      #   puts(x + y)
      class ParenthesesAsGroupedExpression < Cop
        include RangeHelp

        MSG = '`(...)` interpreted as grouped expression.'

        def on_send(node)
          return unless node.arguments.one?
          return if node.operator_method? || node.setter_method?

          return unless node.first_argument.source.start_with?('(')

          space_length = spaces_before_left_parenthesis(node)
          return unless space_length.positive?

          range = space_range(node.first_argument.source_range, space_length)

          add_offense(nil, location: range)
        end
        alias on_csend on_send

        private

        def spaces_before_left_parenthesis(node)
          receiver = node.receiver
          receiver_length = if receiver
                              receiver.source.length
                            else
                              0
                            end
          without_receiver = node.source[receiver_length..-1]

          # Escape question mark if any.
          method_regexp = Regexp.escape(node.method_name)

          match = without_receiver.match(/^\s*&?\.?\s*#{method_regexp}(\s+)\(/)
          match ? match.captures[0].length : 0
        end

        def space_range(expr, space_length)
          range_between(expr.begin_pos - space_length, expr.begin_pos)
        end
      end
    end
  end
end
