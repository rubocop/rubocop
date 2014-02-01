# encoding: utf-8

module Rubocop
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

          if cond.type == :begin
            return if parens_required?(node)
            # allow safe assignment
            return if safe_assignment?(cond) && safe_assignment_allowed?

            add_offence(cond, :expression, message(node))
          end
        end

        def parens_required?(node)
          expr = node.loc.expression.source
          keyword = node.loc.keyword.source

          expr.start_with?("#{keyword}(")
        end

        def message(node)
          kw = node.loc.keyword.source
          article = kw == 'while' ? 'a' : 'an'
          "Don't use parentheses around the condition of #{article} #{kw}."
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            corrector.remove(node.loc.begin)
            corrector.remove(node.loc.end)
          end
        end
      end
    end
  end
end
