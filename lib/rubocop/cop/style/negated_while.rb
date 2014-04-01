# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of while with a negated condition.
      class NegatedWhile < Cop
        include NegativeConditional

        def on_while(node)
          check(node)
        end

        def error_message
          'Favor `until` over `while` for negative conditions.'
        end

        private

        def autocorrect(node)
          @corrections << lambda do |corrector|
            condition, _body, _rest = *node
            # unwrap the negated portion of the condition (a send node)
            pos_condition, _method, = *condition
            corrector.replace(node.loc.keyword, 'until')
            corrector.replace(condition.loc.expression,
                              pos_condition.loc.expression.source)
          end
        end
      end
    end
  end
end
