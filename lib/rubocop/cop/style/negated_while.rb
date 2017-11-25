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

        def message(node)
          format(MSG, inverse: node.inverse_keyword, current: node.keyword)
        end

        private

        def autocorrect(node)
          negative_conditional_corrector(node)
        end
      end
    end
  end
end
