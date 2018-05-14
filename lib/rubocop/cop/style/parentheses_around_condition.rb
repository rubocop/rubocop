# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of superfluous parentheses around the
      # condition of if/unless/while/until.
      #
      # @example
      #   # bad
      #   x += 1 while (x < 10)
      #   foo unless (bar || baz)
      #
      #   if (x > 10)
      #   elsif (x < 3)
      #   end
      #
      #   # good
      #   x += 1 while x < 10
      #   foo unless bar || baz
      #
      #   if x > 10
      #   elsif x < 3
      #   end
      #
      # @example AllowInMultilineConditions: false (default)
      #   # bad
      #   if (x > 10 &&
      #      y > 10)
      #   end
      #
      #   # good
      #    if x > 10 &&
      #       y > 10
      #    end
      #
      # @example AllowInMultilineConditions: true
      #   # good
      #   if (x > 10 &&
      #      y > 10)
      #   end
      class ParenthesesAroundCondition < Cop
        include SafeAssignment
        include Parentheses

        def on_if(node)
          return if node.ternary?

          process_control_op(node)
        end

        def on_while(node)
          process_control_op(node)
        end
        alias on_until on_while

        def autocorrect(node)
          ParenthesesCorrector.correct(node)
        end

        private

        def_node_matcher :control_op_condition, <<-PATTERN
          (begin $_ ...)
        PATTERN

        def process_control_op(node)
          cond = node.condition

          control_op_condition(cond) do |first_child|
            return if modifier_op?(first_child)
            return if parens_allowed?(cond)

            add_offense(cond)
          end
        end

        def modifier_op?(node)
          return false if node.if_type? && node.ternary?
          return true if node.rescue_type?

          MODIFIER_NODES.include?(node.type) && node.modifier_form?
        end

        def message(node)
          kw = node.parent.keyword
          article = kw == 'while' ? 'a' : 'an'
          "Don't use parentheses around the condition of #{article} `#{kw}`."
        end

        def parens_allowed?(node)
          parens_required?(node) ||
            (safe_assignment?(node) && safe_assignment_allowed?) ||
            (node.multiline? && allow_multiline_conditions?)
        end

        def allow_multiline_conditions?
          cop_config['AllowInMultilineConditions']
        end
      end
    end
  end
end
