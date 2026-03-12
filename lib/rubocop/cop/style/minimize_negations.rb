# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Minimizes the number of negations in an `if` or `unless` using De Morgan's
      # laws. This cop only checks conditions that use a single type of boolean
      # operator (`&&`, `||`, `and`, or `or`) and where negated terms are in the
      # majority. Mixed boolean operators are ignored to avoid precedence changes
      # during autocorrection (for example, `unless !x && !y || z`).
      #
      # @example EnforcedStyle: unless (default)
      #
      #   # bad (all terms negated)
      #   do_something unless !x && !y
      #
      #   # good (all terms positive)
      #   do_something if x || y
      #
      # @example EnforcedStyle: if
      #
      #   # bad (all terms negated)
      #   do_something if !x && !y
      #
      #   # good (all terms positive)
      #   do_something unless x || y
      #
      # @example EnforcedStyle: both
      #
      #   # bad (2 negations, 1 positive)
      #   do_something unless !x || !y || z
      #
      #   # good (2 positives, 1 negation)
      #   do_something if x && y && !z
      #
      class MinimizeNegations < Base
        extend AutoCorrector
        include ConfigurableEnforcedStyle

        MSG = 'Avoid `%<keyword>s` with many negations.'

        def on_if(node)
          return if node.ternary? || node.elsif?
          return unless target_conditional?(node)
          return unless node.condition.respond_to?(:conditions)

          operators, conditions = operator_lookup(node.condition)
          return unless should_check?(node, operators, conditions)

          add_offense(node, message: format(MSG, keyword: node.keyword)) do |corrector|
            autocorrect(node, corrector, conditions, operators)
          end
        end

        private

        def target_conditional?(node)
          node.unless? ? target_unless? : target_if?
        end

        def target_if?
          %i[both if].include?(style)
        end

        def target_unless?
          %i[both unless].include?(style)
        end

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
            negate_known_condition(condition, corrector)
          elsif condition.send_type? && condition.comparison_method?
            corrector.wrap(condition, '!(', ')')
          else
            corrector.insert_before(condition, '!')
          end
        end

        def negate_known_condition(condition, corrector)
          if inequality?(condition)
            operator = condition.loc.operator || condition.loc.selector
            corrector.replace(operator, '==')
            return
          end

          corrector.replace(condition, condition.children.first.source)
        end

        def should_check?(node, operators, conditions)
          return false if mixed_operators?(node, operators)

          negated_conditions = conditions.count { |condition| negated?(condition) }
          negated_conditions > conditions.size - negated_conditions
        end

        def mixed_operators?(node, operators)
          operators.any? { |operator| operator.type != node.condition.type }
        end

        def negated?(condition)
          return true if inequality?(condition)
          return false unless negation_method?(condition)

          child = unwrap_begin_child(condition)
          return true if child.begin_type? && child.children.empty?
          return false if child.begin_type?
          return false if negation_method?(child)

          true
        end

        def unwrap_begin_child(condition)
          child = condition.children.first
          return child unless child.begin_type?
          return child.children.first if child.children.one?

          child
        end

        def inequality?(condition)
          condition.send_type? && condition.method?(:!=)
        end

        def negation_method?(condition)
          condition.respond_to?(:negation_method?) && condition.negation_method?
        end

        def operator_lookup(operator)
          operators = []
          conditions = []

          while operator.lhs.operator_keyword?
            operators << operator
            conditions << operator.rhs

            operator = operator.lhs
          end

          operators << operator
          conditions << operator.rhs
          conditions << operator.lhs

          [operators, conditions]
        end
      end
    end
  end
end
