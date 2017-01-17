# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of if with a negated condition. Only ifs
      # without else are considered.
      class NegatedIf < Cop
        include NegativeConditional

        MSG = 'Favor `%s` over `%s` for negative conditions.'.freeze

        def on_if(node)
          return if node.elsif? || node.ternary?

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
