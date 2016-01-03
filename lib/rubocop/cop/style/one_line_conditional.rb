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
      end
    end
  end
end
