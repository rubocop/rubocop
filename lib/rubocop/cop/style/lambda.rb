# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of the pre 1.9 lambda syntax for one-line
      # anonymous functions and uses of the 1.9 lambda syntax for multi-line
      # anonymous functions.
      class Lambda < Cop
        SINGLE_MSG = 'Use the new lambda literal syntax `->(params) {...}`.'
        MULTI_MSG = 'Use the `lambda` method for multi-line lambdas.'

        TARGET = s(:send, nil, :lambda)

        def on_block(node)
          # We're looking for
          # (block
          #   (send nil :lambda)
          #   ...)
          block_method, = *node

          return unless block_method == TARGET
          selector = block_method.loc.selector.source
          lambda_length = lambda_length(node)

          if selector != '->' && lambda_length == 0
            add_offense(block_method, :expression, SINGLE_MSG)
          elsif selector == '->' && lambda_length > 0
            add_offense(block_method, :expression, MULTI_MSG)
          end
        end

        private

        def lambda_length(block_node)
          start_line = block_node.loc.begin.line
          end_line = block_node.loc.end.line

          end_line - start_line
        end
      end
    end
  end
end
