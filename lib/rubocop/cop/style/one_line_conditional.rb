# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # TODO: Make configurable.
      # Checks for uses of if/then/else/end on a single line.
      class OneLineConditional < Cop
        include OnNormalIfUnless

        MSG = 'Favor the ternary operator (`?:`) ' \
              'over `%s/then/else/end` constructs.'.freeze

        def on_normal_if_unless(node)
          return unless node.single_line? && node.else_branch

          add_offense(node)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, replacement(node))
          end
        end

        def message(node)
          format(MSG, node.keyword)
        end

        def replacement(node)
          return to_ternary(node) unless node.parent

          if %i[and or].include?(node.parent.type)
            return "(#{to_ternary(node)})"
          end

          if node.parent.send_type? && operator?(node.parent.method_name)
            return "(#{to_ternary(node)})"
          end

          to_ternary(node)
        end

        def to_ternary(node)
          cond, body, else_clause = *node
          "#{expr_replacement(cond)} ? #{expr_replacement(body)} : " \
            "#{expr_replacement(else_clause)}"
        end

        def expr_replacement(node)
          requires_parentheses?(node) ? "(#{node.source})" : node.source
        end

        def requires_parentheses?(node)
          return true if %i[and or if].include?(node.type)
          return true if node.assignment?
          return true if method_call_with_changed_precedence?(node)

          keyword_with_changed_precedence?(node)
        end

        def method_call_with_changed_precedence?(node)
          return false unless node.send_type?
          return false if node.method_args.empty?
          return false if parenthesized_call?(node)

          !operator?(node.method_name)
        end

        def keyword_with_changed_precedence?(node)
          return false unless node.keyword?
          return true if node.keyword_not?

          !parenthesized_call?(node)
        end
      end
    end
  end
end
