# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of superfluous parentheses around the
      # condition of if/unless/while/until.
      class ParenthesesAroundCondition < Cop
        include IfNode
        include SafeAssignment

        def on_if(node)
          return if ternary_op?(node)
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

          return unless cond.type == :begin
          # handle `if (something rescue something_else) ...`
          return if modifier_op?(cond.children.first)
          # check if there's any whitespace between the keyword and the cond
          return if parens_required?(node)
          # allow safe assignment
          return if safe_assignment?(cond) && safe_assignment_allowed?

          add_offense(cond, :expression, message(node))
        end

        def modifier_op?(node)
          return false if ternary_op?(node)
          return true if node.type == :rescue

          [:if, :while, :until].include?(node.type) &&
            node.loc.end.nil?
        end

        def parens_required?(node)
          exp = node.loc.expression
          kw = node.loc.keyword
          kw_offset = kw.begin_pos - exp.begin_pos

          exp.source[kw_offset..-1].start_with?(kw.source + '(')
        end

        def message(node)
          kw = node.loc.keyword.source
          article = kw == 'while' ? 'a' : 'an'
          "Don't use parentheses around the condition of #{article} `#{kw}`."
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end
    end
  end
end
