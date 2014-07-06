# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # TODO: Make configurable.
      # Checks for uses of if/then/else/end on a single line.
      class OneLineConditional < Cop
        include OnNormalIfUnless

        MSG = 'Favor the ternary operator (?:) ' \
              'over if/then/else/end constructs.'

        def on_normal_if_unless(node)
          return if node.loc.expression.source.include?("\n")
          add_offense(node, :expression, MSG)
        end
      end
    end
  end
end
