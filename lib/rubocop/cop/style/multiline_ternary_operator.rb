# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for multi-line ternary op expressions.
      #
      # NOTE: `return if ... else ... end` is syntax error. If `return` is used before
      # multiline ternary operator expression, it will be auto-corrected to single-line
      # ternary operator. The same is true for `break`, `next`, and method call.
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
      #   return cond ?
      #          b :
      #          c
      #
      #   # good
      #   a = cond ? b : c
      #   a = if cond
      #     b
      #   else
      #     c
      #   end
      #
      #   return cond ? b : c
      #
      class MultilineTernaryOperator < Base
        extend AutoCorrector

        MSG_IF = 'Avoid multi-line ternary operators, use `if` or `unless` instead.'
        MSG_SINGLE_LINE = 'Avoid multi-line ternary operators, use single-line instead.'
        SINGLE_LINE_TYPES = %i[return break next send].freeze

        def on_if(node)
          return unless offense?(node)

          message = enforce_single_line_ternary_operator?(node) ? MSG_SINGLE_LINE : MSG_IF

          add_offense(node, message: message) do |corrector|
            next unless offense?(node)

            corrector.replace(node, replacement(node))
          end
        end

        private

        def offense?(node)
          node.ternary? && node.multiline?
        end

        def replacement(node)
          if enforce_single_line_ternary_operator?(node)
            "#{node.condition.source} ? #{node.if_branch.source} : #{node.else_branch.source}"
          else
            <<~RUBY.chop
              if #{node.condition.source}
                #{node.if_branch.source}
              else
                #{node.else_branch.source}
              end
            RUBY
          end
        end

        def enforce_single_line_ternary_operator?(node)
          SINGLE_LINE_TYPES.include?(node.parent.type)
        end
      end
    end
  end
end
