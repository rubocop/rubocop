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
      #   do_something (foo)
      #
      #   # good
      #   do_something(foo)
      #   do_something (2 + 3) * 4
      #   do_something (foo * bar).baz
      class ParenthesesAsGroupedExpression < Cop
        include RangeHelp

        MSG = '`(...)` interpreted as grouped expression.'

        def on_send(node)
          return unless node.arguments.one?
          return if node.operator_method? || node.setter_method?
          return if grouped_parentheses?(node)

          space_length = spaces_before_left_parenthesis(node)
          return unless space_length.positive?

          range = space_range(node.first_argument.source_range, space_length)

          add_offense(node, location: range)
        end
        alias on_csend on_send

        def autocorrect(node)
          space_length = spaces_before_left_parenthesis(node)
          range = space_range(node.first_argument.source_range, space_length)

          lambda do |corrector|
            corrector.remove(range)
          end
        end

        private

        def grouped_parentheses?(node)
          first_argument = node.first_argument

          first_argument.send_type? && first_argument.receiver&.begin_type?
        end

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
