# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # TODO: Make configurable.
      # Checks for uses of if/then/else/end on a single line.
      #
      # @example
      #   # bad
      #   if foo then boo else doo end
      #   unless foo then boo else goo end
      #
      #   # good
      #   foo ? boo : doo
      #   boo if foo
      #   if foo then boo end
      #
      #   # good
      #   if foo
      #     boo
      #   else
      #     doo
      #   end
      class OneLineConditional < Cop
        include OnNormalIfUnless

        MSG = 'Favor the ternary operator (`?:`) ' \
              'over `%<keyword>s/then/else/end` constructs.'

        def on_normal_if_unless(node)
          return unless node.single_line? && node.else_branch

          add_offense(node)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, replacement(node))
          end
        end

        private

        def message(node)
          format(MSG, keyword: node.keyword)
        end

        def replacement(node)
          return to_ternary(node) unless node.parent

          if %i[and or].include?(node.parent.type)
            return "(#{to_ternary(node)})"
          end

          if node.parent.send_type? && node.parent.operator_method?
            return "(#{to_ternary(node)})"
          end

          to_ternary(node)
        end

        def to_ternary(node)
          condition, if_branch, else_branch = *node

          "#{expr_replacement(condition)} ? " \
            "#{expr_replacement(if_branch)} : " \
            "#{expr_replacement(else_branch)}"
        end

        def expr_replacement(node)
          return 'nil' if node.nil?

          requires_parentheses?(node) ? "(#{node.source})" : node.source
        end

        def requires_parentheses?(node)
          return true if %i[and or if].include?(node.type)
          return true if node.assignment?
          return true if method_call_with_changed_precedence?(node)

          keyword_with_changed_precedence?(node)
        end

        def method_call_with_changed_precedence?(node)
          return false unless node.send_type? && node.arguments?
          return false if node.parenthesized_call?

          !node.operator_method?
        end

        def keyword_with_changed_precedence?(node)
          return false unless node.keyword?
          return true if node.prefix_not?

          node.arguments? && !node.parenthesized_call?
        end
      end
    end
  end
end
