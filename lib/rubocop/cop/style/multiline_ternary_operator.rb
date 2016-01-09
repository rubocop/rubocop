# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for multi-line ternary op expressions.
      class MultilineTernaryOperator < Cop
        MSG = 'Avoid multi-line ?: (the ternary operator);' \
              ' use `if`/`unless` instead.'.freeze

        def on_if(node)
          _condition, _if_branch, else_branch = *node
          loc = node.loc

          # discard non-ternary ops
          return unless loc.respond_to?(:question)

          add_offense(node, :expression) if loc.line != else_branch.loc.line
        end
      end
    end
  end
end
