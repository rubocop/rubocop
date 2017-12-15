# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for multi-line ternary op expressions.
      #
      # @example
      #   # bad
      #   a = cond ?
      #     b : c
      #   a = cond ? b :
      #       c
      #   a = cond ?
      #       b :
      #       c
      #
      #   # good
      #   a = cond ? b : c
      #   a =
      #     if cond
      #       b
      #     else
      #       c
      #     end
      class MultilineTernaryOperator < Cop
        MSG = 'Avoid multi-line ternary operators, ' \
              'use `if` or `unless` instead.'.freeze

        def on_if(node)
          return unless node.ternary? && node.multiline?

          add_offense(node)
        end
      end
    end
  end
end
