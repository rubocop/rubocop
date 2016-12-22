# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for space between a the name of a called method and a left
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
        MSG = '`(...)` interpreted as grouped expression.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node
          return unless args.one?
          return if operator?(method_name) || node.asgn_method_call?

          first_arg = args.first
          return unless first_arg.source.start_with?('(')

          space_length = spaces_before_left_parenthesis(node)
          return unless space_length > 0

          add_offense(nil, space_range(first_arg.source_range, space_length))
        end

        private

        def spaces_before_left_parenthesis(node)
          receiver, method_name, _args = *node
          receiver_length = if receiver
                              receiver.source.length
                            else
                              0
                            end
          without_receiver = node.source[receiver_length..-1]

          # Escape question mark if any.
          method_regexp = Regexp.escape(method_name)

          match = without_receiver.match(/^\s*\.?\s*#{method_regexp}(\s+)\(/)
          match ? match.captures[0].length : 0
        end

        def space_range(expr, space_length)
          range_between(expr.begin_pos - space_length, expr.begin_pos)
        end
      end
    end
  end
end
