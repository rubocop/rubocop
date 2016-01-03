# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for *unless* expressions with *else* clauses.
      class UnlessElse < Cop
        MSG = 'Do not use `unless` with `else`. Rewrite these with the ' \
              'positive case first.'.freeze

        def on_if(node)
          loc = node.loc

          # discard ternary ops and modifier if/unless nodes
          return unless loc.respond_to?(:keyword) && loc.respond_to?(:else)
          return unless loc.keyword.is?('unless') && loc.else

          add_offense(node, :expression)
        end
      end
    end
  end
end
