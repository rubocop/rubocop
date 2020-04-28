# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop can either enforce or forbid Yoda conditions,
      # i.e. comparison operations where the order of expression is reversed.
      # eg. `5 == x`
      #
      # @example EnforcedStyle: forbid_for_all_comparison_operators (default)
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
      # @example EnforcedStyle: forbid_for_equality_operators_only
      #   # bad
      #   99 == foo
      #   "bar" != foo
      #
      #   # good
      #   99 >= foo
      #   3 < a && a < 5
      #
      # @example EnforcedStyle: require_for_all_comparison_operators
      #   # bad
      #   foo == 99
      #   foo == "bar"
      #   foo <= 42
      #   bar > 10
      #
      #   # good
      #   99 == foo
      #   "bar" != foo
      #   42 >= foo
      #   10 < bar
      #
      # @example EnforcedStyle: require_for_equality_operators_only
      #   # bad
      #   99 >= foo
      #   3 < a && a < 5
      #
      #   # good
      #   99 == foo
      #   "bar" != foo
      class YodaCondition < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG = 'Reverse the order of the operands `%<source>s`.'

        REVERSE_COMPARISON = {
          '<' => '>',
          '<=' => '>=',
          '>' => '<',
          '>=' => '<='
        }.freeze

        EQUALITY_OPERATORS = %i[== !=].freeze

        NONCOMMUTATIVE_OPERATORS = %i[===].freeze

        PROGRAM_NAMES = %i[$0 $PROGRAM_NAME].freeze

        def_node_matcher :file_constant_equal_program_name?, <<~PATTERN
          (send #source_file_path_constant? {:== :!=} (gvar #program_name?))
        PATTERN

        def on_send(node)
          return unless yoda_compatible_condition?(node)
          return if equality_only? && non_equality_operator?(node) ||
                    file_constant_equal_program_name?(node)

          valid_yoda?(node) || add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(actual_code_range(node), corrected_code(node))
          end
        end

        private

        def enforce_yoda?
          style == :require_for_all_comparison_operators ||
            style == :require_for_equality_operators_only
        end

        def equality_only?
          style == :forbid_for_equality_operators_only ||
            style == :require_for_equality_operators_only
        end

        def yoda_compatible_condition?(node)
          node.comparison_method? &&
            !noncommutative_operator?(node)
        end

        def valid_yoda?(node)
          lhs = node.receiver
          rhs = node.first_argument

          return true if lhs.literal? && rhs.literal? ||
                         !lhs.literal? && !rhs.literal?

          enforce_yoda? ? lhs.literal? : rhs.literal?
        end

        def message(node)
          format(MSG, source: node.source)
        end

        def corrected_code(node)
          lhs = node.receiver
          rhs = node.first_argument

          "#{rhs.source} #{reverse_comparison(node.method_name)} #{lhs.source}"
        end

        def actual_code_range(node)
          range_between(
            node.loc.expression.begin_pos, node.loc.expression.end_pos
          )
        end

        def reverse_comparison(operator)
          REVERSE_COMPARISON.fetch(operator.to_s, operator)
        end

        def non_equality_operator?(node)
          !EQUALITY_OPERATORS.include?(node.method_name)
        end

        def noncommutative_operator?(node)
          NONCOMMUTATIVE_OPERATORS.include?(node.method_name)
        end

        def source_file_path_constant?(node)
          node.source == '__FILE__'
        end

        def program_name?(name)
          PROGRAM_NAMES.include?(name)
        end
      end
    end
  end
end
