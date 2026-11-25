# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for the use of logical operators in an `unless` condition.
      # It discourages such code, as the condition becomes more difficult
      # to read and understand.
      #
      # This cop supports two styles:
      #
      # - `forbid_mixed_logical_operators` (default)
      # - `forbid_logical_operators`
      #
      # `forbid_mixed_logical_operators` style forbids the use of more than one type
      # of logical operators. This makes the `unless` condition easier to read
      # because either all conditions need to be met or any condition needs to be met
      # in order for the expression to be truthy or falsey.
      #
      # `forbid_logical_operators` style forbids any use of logical operators.
      # This makes it even easier to read the `unless` condition as
      # there is only one condition in the expression.
      #
      # @example EnforcedStyle: forbid_mixed_logical_operators (default)
      #   # bad
      #   return unless a || b && c
      #   return unless a && b || c
      #   return unless a && b and c
      #   return unless a || b or c
      #   return unless a && b or c
      #   return unless a || b and c
      #
      #   # good
      #   return unless a && b && c
      #   return unless a || b || c
      #   return unless a and b and c
      #   return unless a or b or c
      #   return unless a?
      #
      # @example EnforcedStyle: forbid_logical_operators
      #   # bad
      #   return unless a || b
      #   return unless a && b
      #   return unless a or b
      #   return unless a and b
      #
      #   # good
      #   return unless a
      #   return unless a?
      class UnlessLogicalOperators < Base
        include ConfigurableEnforcedStyle

        FORBID_MIXED_LOGICAL_OPERATORS = 'Do not use mixed logical operators in an `unless`.'
        FORBID_LOGICAL_OPERATORS = 'Do not use any logical operator in an `unless`.'

        # @!method or_with_and?(node)
        def_node_matcher :or_with_and?, <<~PATTERN
          (or <`and ...> )
        PATTERN

        # @!method and_with_or?(node)
        def_node_matcher :and_with_or?, <<~PATTERN
          (and <`or ...> )
        PATTERN

        def on_if(node)
          return unless node.unless?

          condition = unparenthesized_condition(node)

          if style == :forbid_mixed_logical_operators && mixed_logical_operator?(condition)
            add_offense(node, message: FORBID_MIXED_LOGICAL_OPERATORS)
          elsif style == :forbid_logical_operators && condition.operator_keyword?
            add_offense(node, message: FORBID_LOGICAL_OPERATORS)
          end
        end

        private

        def unparenthesized_condition(node)
          condition = node.condition
          while condition.begin_type? && condition.children.one?
            condition = condition.children.first
          end
          condition
        end

        def mixed_logical_operator?(condition)
          or_with_and?(condition) ||
            and_with_or?(condition) ||
            mixed_precedence_and?(condition) ||
            mixed_precedence_or?(condition)
        end

        def mixed_precedence_and?(condition)
          and_sources = condition.each_descendant(:and).map(&:operator)
          and_sources << condition.operator if condition.and_type?

          !(and_sources.all?('&&') || and_sources.all?('and'))
        end

        def mixed_precedence_or?(condition)
          or_sources = condition.each_descendant(:or).map(&:operator)
          or_sources << condition.operator if condition.or_type?

          !(or_sources.all?('||') || or_sources.all?('or'))
        end
      end
    end
  end
end
