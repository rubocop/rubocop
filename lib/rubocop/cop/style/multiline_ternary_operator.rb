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
      #   a = if cond
      #     b
      #   else
      #     c
      #   end
      class MultilineTernaryOperator < Base
        extend AutoCorrector

        MSG = 'Avoid multi-line ternary operators, ' \
              'use `if` or `unless` instead.'

        def on_if(node)
          return unless node.ternary? && node.multiline?

          add_offense(node) do |corrector|
            corrector.replace(node, <<~RUBY.chop)
              if #{node.condition.source}
                #{node.if_branch.source}
              else
                #{node.else_branch.source}
              end
            RUBY
          end
        end
      end
    end
  end
end
