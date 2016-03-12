# encoding: utf-8
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
          exp = node.source
          return if exp.include?("\n")
          return unless node.loc.respond_to?(:else) && node.loc.else
          condition = exp.include?('if') ? 'if' : 'unless'

          add_offense(node, :expression, format(MSG, condition))
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.replace(node.source_range, replacement(node))
          end
        end

        def replacement(node)
          return ternary(node) unless node.parent
          return "(#{ternary(node)})" if [:and, :or].include?(node.parent.type)

          if node.parent.send_type? && operator?(node.parent.method_name)
            return "(#{ternary(node)})"
          end

          ternary(node)
        end

        def ternary(node)
          cond, body, else_clause = *node
          "#{expr_replacement(cond)} ? #{expr_replacement(body)} : " +
            expr_replacement(else_clause)
        end

        def expr_replacement(node)
          requires_parentheses?(node) ? "(#{node.source})" : node.source
        end

        def requires_parentheses?(node)
          return true if [:and, :or, :if].include?(node.type)
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
