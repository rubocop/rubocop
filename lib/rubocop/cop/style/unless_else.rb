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
          return unless loc.keyword.is?('unless'.freeze) && loc.else

          add_offense(node, :expression)
        end

        def autocorrect(node)
          condition, = *node
          body_range = range_between_condition_and_else(node, condition)
          else_range = range_between_else_and_end(node)

          lambda do |corrector|
            corrector.replace(node.loc.keyword, 'if'.freeze)
            corrector.replace(body_range, else_range.source)
            corrector.replace(else_range, body_range.source)
          end
        end

        def range_between_condition_and_else(node, condition)
          range_between(condition.source_range.end_pos, node.loc.else.begin_pos)
        end

        def range_between_else_and_end(node)
          range_between(node.loc.else.end_pos, node.loc.end.begin_pos)
        end
      end
    end
  end
end
