# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for the presence of ternary operators.
      class TernaryOperator < Cop
        MSG = 'Do not use ternary operators, ' \
              'use `if / else` instead.'.freeze

        def on_if(node)
          return unless node.ternary?

          add_offense(node)
        end
      end
    end
  end
end
