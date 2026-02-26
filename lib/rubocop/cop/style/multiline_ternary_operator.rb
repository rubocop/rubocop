# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for multi-line ternary op expressions.
      #
      # NOTE: `return if ... else ... end` is syntax error. If `return` is used before
      # multiline ternary operator expression, it cannot be auto-corrected.
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
          return unless offense?(node)

          add_offense(node) do |corrector|
            # `return if ... else ... end` is syntax error. If `return` is used before
            # multiline ternary operator expression, it cannot be auto-corrected.
            next unless offense?(node) && !node.parent.return_type?

            corrector.replace(node, <<~RUBY.chop)
              if #{node.condition.source}
                #{node.if_branch.source}
              else
                #{node.else_branch.source}
              end
            RUBY
          end
        end

        private

        def offense?(node)
          node.ternary? && node.multiline?
        end
      end
    end
  end
end
