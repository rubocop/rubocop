# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for expressions where there is a call to a predicate
      # method with at least one argument, where no parentheses are used around
      # the parameter list, and a boolean operator, && or ||, is used in the
      # last argument.
      #
      # The idea behind warning for these constructs is that the user might
      # be under the impression that the return value from the method call is
      # an operand of &&/||.
      #
      # @example
      #
      #   # bad
      #
      #   if day.is? :tuesday && month == :jan
      #     ...
      #   end
      #
      # @example
      #
      #   # good
      #
      #   if day.is?(:tuesday) && month == :jan
      class RequireParentheses < Cop
        MSG = 'Use parentheses in the method call to avoid confusion about ' \
              'precedence.'.freeze

        def on_send(node)
          _receiver, method_name, *args = *node

          return if parentheses?(node) || args.empty?

          if args.first.if_type? && args.first.ternary?
            check_ternary(args.first, node)
          elsif method_name.to_s.end_with?('?')
            check_predicate(args.last, node)
          end
        end

        private

        def check_ternary(ternary, node)
          return unless offense?(ternary.condition)

          range = range_between(node.source_range.begin_pos,
                                ternary.condition.source_range.end_pos)

          add_offense(range, range)
        end

        def check_predicate(predicate, node)
          return unless offense?(predicate)

          add_offense(node, :expression)
        end

        def offense?(node)
          [:and, :or].include?(node.type)
        end
      end
    end
  end
end
