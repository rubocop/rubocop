# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for ternary expressions.
      class TernaryOperator < Cop
        include StatementModifier

        def error_message
          'Avoid ternary operators (boolean ? true : false). Use multi-line ' \
            'if instead to emphasize code branches.'
        end

        def on_if(node)
          return unless ternary_op?(node)

          add_offense(node, :expression, error_message)
        end
      end
    end
  end
end
