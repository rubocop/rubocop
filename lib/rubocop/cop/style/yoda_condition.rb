# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for Yoda conditions, i.e. comparison operations where
      # readability is reduced because the operands are not ordered the same
      # way as they would be ordered in spoken English.
      #
      # @example
      #
      #   # EnforcedStyle: all_comparison_operators
      #
      #   # bad
      #   99 == foo
      #   "bar" != foo
      #   42 >= foo
      #   10 < bar
      #
      #   # good
      #   foo == 99
      #   foo == "bar"
      #   foo <= 42
      #   bar > 10
      #
      # @example
      #
      #   # EnforcedStyle: equality_operators_only
      #
      #   # bad
      #   99 == foo
      #   "bar" != foo
      #
      #   # good
      #   99 >= foo
      #   3 < a && a < 5
      class YodaCondition < Cop
        include ConfigurableEnforcedStyle

        MSG = 'Reverse the order of the operands `%s`.'.freeze

        REVERSE_COMPARISON = {
          '<' => '>',
          '<=' => '>=',
          '>' => '<',
          '>=' => '<='
        }.freeze

        EQUALITY_OPERATORS = %i[== !=].freeze

        NONCOMMUTATIVE_OPERATORS = %i[===].freeze

        def on_send(node)
          return unless yoda_condition?(node)

          add_offense(node)
        end

        private

        def yoda_condition?(node)
          return false unless node.comparison_method?

          lhs, operator, rhs = *node
          if check_equality_only?
            return false if non_equality_operator?(operator)
          end

          return false if noncommutative_operator?(operator)

          lhs.literal? && !rhs.literal?
        end

        def message(node)
          format(MSG, node.source)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(actual_code_range(node), corrected_code(node))
          end
        end

        def corrected_code(node)
          lhs, operator, rhs = *node
          "#{rhs.source} #{reverse_comparison(operator)} #{lhs.source}"
        end

        def actual_code_range(node)
          range_between(
            node.loc.expression.begin_pos, node.loc.expression.end_pos
          )
        end

        def reverse_comparison(operator)
          REVERSE_COMPARISON.fetch(operator.to_s, operator)
        end

        def check_equality_only?
          style == :equality_operators_only
        end

        def non_equality_operator?(operator)
          !EQUALITY_OPERATORS.include?(operator)
        end

        def noncommutative_operator?(operator)
          NONCOMMUTATIVE_OPERATORS.include?(operator)
        end
      end
    end
  end
end
