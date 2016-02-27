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
          cond, body, else_clause = *node
          ternary = "#{cond.source} ? #{body.source} : #{else_clause.source}"

          return ternary unless node.parent
          return "(#{ternary})" if [:and, :or].include?(node.parent.type)

          if node.parent.send_type?
            _receiver, method_name, = *node.parent
            return "(#{ternary})" if operator?(method_name)
          end

          ternary
        end
      end
    end
  end
end
