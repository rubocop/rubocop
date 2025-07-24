# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Minimizes the number of negations in an `unless` using De Morgan’s laws.
      #
      # @example
      #
      #   # bad (all terms negated)
      #   do_something unless !x && !y
      #
      #   # good (all terms positive)
      #   do_something if x || y
      #
      # @example
      #
      #   # bad (2 negations, 1 positive)
      #   do_something unless !x || !y || z
      #
      #   # good (2 positives, 1 negation)
      #   do_something if x && y && !z
      #
      class UnlessMinimizeNegations < Base
        extend AutoCorrector

        MSG = 'Avoid `unless` with many negations.'

        def on_if(node)
          return if !node.unless? || !node.condition.respond_to?(:conditions)

          operators, conditions = operator_lookup(node.condition)
          return unless should_check?(node, operators, conditions)

          add_offense(node) do |corrector|
            autocorrect(node, corrector, conditions, operators)
          end
        end

        private

        def autocorrect(node, corrector, conditions, operators)
          corrector.replace(node.loc.keyword, node.inverse_keyword)

          operators.each do |operator|
            corrector.replace(operator.loc.operator, operator.inverse_operator)
          end

          conditions.each do |condition|
            negate_condition(condition, corrector)
          end
        end

        def negate_condition(condition, corrector)
          if negated?(condition)
            corrector.replace(condition, condition.children.first.source)
          elsif condition.send_type? && condition.comparison_method? && !condition.parenthesized?
            corrector.wrap(condition, '!(', ')')
          else
            corrector.insert_before(condition, '!')
          end
        end

        def should_check?(node, operators, conditions)
          return false if conditions.size < 2
          return false if mixed_operators?(node, operators)

          negated_conditions = conditions.count { |condition| negated?(condition) }
          negated_conditions > conditions.size - negated_conditions
        end

        def mixed_operators?(node, operators)
          operators.any? { |operator| operator.type != node.condition.type }
        end

        def negated?(condition)
          condition.respond_to?(:negation_method?) && condition.negation_method?
        end

        def operator_lookup(operator)
          operators = []
          conditions = []

          loop do
            operators << operator
            conditions << operator.rhs

            if operator.lhs.operator_keyword?
              operator = operator.lhs
            else
              conditions << operator.lhs
              break
            end
          end

          [operators, conditions]
        end
      end
    end
  end
end
