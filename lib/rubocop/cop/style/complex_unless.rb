# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for complex `unless` conditions and prefers `if` for readability.
      #
      # A condition is considered complex when it contains:
      # - a disjunction (`||`/`or`), or
      # - a negation combined with logical operators (e.g. `foo && !bar`), or
      # - multiple negations (e.g. `!!foo`).
      #
      # Simple conjunctions like `unless foo && bar` are not offenses.
      # A single negated condition like `unless !foo` is ignored to avoid
      # overlapping with `Style/NegatedUnless`.
      #
      # This cop only inverts the condition to switch from `unless` to `if`.
      # It does not try to reduce the number of negations; that responsibility
      # belongs to `Style/MinimizeNegations`.
      #
      # @example
      #   # bad
      #   do_something unless foo || bar
      #   do_something unless foo || !bar
      #   do_something unless foo && !bar
      #   do_something unless !foo || bar || baz
      #   do_something unless !!foo
      #
      #   # good
      #   do_something unless foo
      #   do_something unless foo && bar
      #   do_something unless !foo
      #   do_something if !foo && !bar
      #   do_something if !foo || bar
      #   do_something if foo && !bar && !baz
      #
      # @example MinOperatorCount: 2
      #   # good
      #   do_something unless foo || bar
      #
      #   # bad
      #   do_something unless foo || bar || baz
      #
      class ComplexUnless < Base
        extend AutoCorrector

        MSG = 'Prefer `if` over complex `unless` for better readability.'

        def on_if(node)
          return unless node.unless?

          condition = node.condition
          return unless complex_condition?(condition)

          add_offense(node.loc.keyword) do |corrector|
            replacement = inverted_condition_source(condition)
            corrector.replace(node.loc.keyword, node.inverse_keyword)
            corrector.replace(condition, replacement)
          end
        end

        private

        def complex_condition?(condition)
          condition = unwrap_begin(condition)
          return false if condition.assignment? || condition.type?(:any_block)
          return false unless meets_complexity_threshold?(condition)

          contains_or?(condition) ||
            negation_with_operator?(condition) ||
            multiple_negations?(condition)
        end

        def contains_or?(condition)
          condition.or_type? || condition_descendants(condition).any?(&:or_type?)
        end

        def contains_negation?(condition)
          explicit_negation?(condition) ||
            condition_descendants(condition).any? { |node| explicit_negation?(node) }
        end

        def explicit_negation?(node)
          node.send_type? && node.negation_method?
        end

        def contains_logical_operator?(condition)
          condition.operator_keyword? || condition_descendants(condition).any?(&:and_type?)
        end

        def negation_with_operator?(condition)
          contains_negation?(condition) && contains_logical_operator?(condition)
        end

        def multiple_negations?(condition)
          negation_count(condition) > 1
        end

        def meets_complexity_threshold?(condition)
          operator_count(condition) >= min_operator_count
        end

        def operator_count(condition)
          logical_operator_count(condition) + negation_count(condition)
        end

        def logical_operator_count(condition)
          count = condition_descendants(condition).count { |node| node.type?(:and, :or) }
          count += 1 if condition.type?(:and, :or)
          count
        end

        def negation_count(condition)
          count = condition_descendants(condition).count { |node| explicit_negation?(node) }
          count + (explicit_negation?(condition) ? 1 : 0)
        end

        def min_operator_count
          Integer(cop_config.fetch('MinOperatorCount', 1))
        end

        def inverted_condition_source(node)
          node = unwrap_begin(node)
          return negated_leaf_source(node) unless node.type?(:and, :or)

          lhs = inverted_condition_source(node.lhs)
          rhs = inverted_condition_source(node.rhs)

          parent_operator = node.inverse_operator
          lhs = parenthesize_if_needed(node.lhs, lhs, parent_operator)
          rhs = parenthesize_if_needed(node.rhs, rhs, parent_operator)

          "#{lhs} #{node.inverse_operator} #{rhs}"
        end

        def parenthesize_if_needed(node, source, parent_operator)
          node = unwrap_begin(node)
          return source unless node.type?(:and, :or)

          return source if node.inverse_operator == parent_operator

          "(#{source})"
        end

        def negated_leaf_source(node)
          base, count = negation_chain(node)
          negation_source(base, count + 1)
        end

        def negation_chain(node)
          count = 0
          while node.send_type? && node.negation_method?
            count += 1
            node = node.children.first
          end

          [node, count]
        end

        def negation_source(node, count)
          node = unwrap_begin(node)
          return node.source if count.even?

          source = node.source
          source = "(#{source})" if needs_parentheses_for_negation?(node)
          "!#{source}"
        end

        def needs_parentheses_for_negation?(node)
          compound_or_grouped_type?(node) ||
            node.assignment? ||
            node.if_type? ||
            (node.send_type? && node.operator_method?)
        end

        def compound_or_grouped_type?(node)
          node.type?(:begin, :kwbegin) ||
            node.operator_keyword? ||
            node.rescue_type?
        end

        def condition_descendants(node)
          results = []
          node.each_child_node do |child|
            next if child.type?(:any_block)

            results << child
            results.concat(condition_descendants(child))
          end
          results
        end

        def unwrap_begin(node)
          return node unless node.type?(:begin, :kwbegin)
          return node.children.first if node.children.one?

          node
        end
      end
    end
  end
end
