# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for lambdas that always return nil, which can be replaced
      # with an empty lambda instead.
      #
      # @example
      #   # bad
      #   -> { nil }
      #
      #   lambda do
      #     next nil
      #   end
      #
      #   # good
      #   -> {}
      #
      #   lambda do
      #   end
      #
      #   -> (x) { nil if x }
      #
      class NilLambda < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Use an empty lambda instead of always returning nil.'

        # @!method nil_return?(node)
        def_node_matcher :nil_return?, <<~PATTERN
          { ({return next break} nil) (nil) }
        PATTERN

        def on_block(node)
          return unless node.lambda?
          return unless nil_return?(node.body)

          add_offense(node) do |corrector|
            range = if node.single_line?
                      range_with_surrounding_space(range: node.body.loc.expression)
                    else
                      range_by_whole_lines(node.body.loc.expression, include_final_newline: true)
                    end

            corrector.remove(range)
          end
        end
      end
    end
  end
end
