# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for places where binary operator has identical operands.
      #
      # It covers arithmetic operators: `+`, `-`, `*`, `/`, `%`, `**`;
      # comparison operators: `==`, `===`, `=~`, `>`, `>=`, `<`, `<=`;
      # bitwise operators: `|`, `^`, `&`, `<<`, `>>`;
      # boolean operators: `&&`, `||`
      # and "spaceship" operator - `<=>`.
      #
      # This cop is marked as unsafe as it does not consider side effects when calling methods
      # and thus can generate false positives:
      #   if wr.take_char == '\0' && wr.take_char == '\0'
      #
      # @example
      #   # bad
      #   x.top >= x.top
      #
      #   if a.x != 0 && a.x != 0
      #     do_something
      #   end
      #
      #   def childs?
      #     left_child || left_child
      #   end
      #
      class BinaryOperatorWithIdenticalOperands < Base
        MSG = 'Binary operator `%<op>s` has identical operands.'
        MATH_OPERATORS = %i[+ - * / % ** << >> | ^].to_set.freeze

        def on_send(node)
          return unless node.binary_operation?

          lhs, operation, rhs = *node
          return if MATH_OPERATORS.include?(node.method_name) && rhs.basic_literal?

          add_offense(node, message: format(MSG, op: operation)) if lhs == rhs
        end

        def on_and(node)
          add_offense(node, message: format(MSG, op: node.operator)) if node.lhs == node.rhs
        end
        alias on_or on_and
      end
    end
  end
end
