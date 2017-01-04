# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of while with a negated condition.
      class NegatedWhile < Cop
        include NegativeConditional

        MSG = 'Favor `%s` over `%s` for negative conditions.'.freeze

        def on_while(node)
          check_negative_conditional(node)
        end

        def on_until(node)
          check_negative_conditional(node)
        end

        def message(node)
          format(MSG, node.inverse_keyword, node.keyword)
        end

        private

        def autocorrect(node)
          negative_conditional_corrector(node)
        end
      end
    end
  end
end
