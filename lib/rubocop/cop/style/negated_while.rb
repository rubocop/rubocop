# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of while with a negated condition.
      class NegatedWhile < Cop
        include NegativeConditional

        def on_while(node)
          check_negative_conditional(node)
        end

        def on_until(node)
          check_negative_conditional(node)
        end

        def autocorrect(node)
          ConditionCorrector.correct_negative_condition(node)
        end

        private

        def message(node)
          format(MSG, inverse: node.inverse_keyword, current: node.keyword)
        end
      end
    end
  end
end
