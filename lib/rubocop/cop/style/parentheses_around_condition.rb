# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of superfluous parentheses around the
      # condition of if/unless/while/until.
      class ParenthesesAroundCondition < Cop
        include IfNode
        include SafeAssignment
        include Parentheses

        def on_if(node)
          return if ternary?(node)
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
          cond, _body = *node

          return unless cond.begin_type?
          # handle `if (something rescue something_else) ...`
          return if modifier_op?(cond.children.first)
          # check if there's any whitespace between the keyword and the cond
          return if parens_required?(node.children.first)
          # allow safe assignment
          return if safe_assignment?(cond) && safe_assignment_allowed?

          add_offense(cond, :expression, message(node))
        end

        def modifier_op?(node)
          return false if ternary?(node)
          return true if node.rescue_type?

          [:if, :while, :until].include?(node.type) &&
            node.loc.end.nil?
        end

        def message(node)
          kw = node.loc.keyword.source
          article = kw == 'while' ? 'a' : 'an'
          "Don't use parentheses around the condition of #{article} `#{kw}`."
        end
      end
    end
  end
end
