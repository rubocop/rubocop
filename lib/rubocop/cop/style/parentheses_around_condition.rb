# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of superfluous parentheses around the
      # condition of if/unless/while/until.
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

        def on_until(node)
          process_control_op(node)
        end

        private

        def process_control_op(node)
          cond = node.condition

          return unless cond.begin_type?
          return if cond.children.empty?
          return if modifier_op?(cond.children.first)
          return if parens_required?(node.children.first)
          return if safe_assignment?(cond) && safe_assignment_allowed?

          add_offense(cond)
        end

        def modifier_op?(node)
          return false if node.if_type? && node.ternary?
          return true if node.rescue_type?

          MODIFIER_NODES.include?(node.type) &&
            node.modifier_form?
        end

        def message(node)
          kw = node.parent.keyword
          article = kw == 'while' ? 'a' : 'an'
          "Don't use parentheses around the condition of #{article} `#{kw}`."
        end
      end
    end
  end
end
