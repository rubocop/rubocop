# encoding: utf-8

module Rubocop
  module Cop
    class Lambda < Cop
      SINGLE_MSG = 'Use the new lambda literal syntax ->(params) {...}.'
      MULTI_MSG = 'Use the lambda method for multi-line lambdas.'

      TARGET = s(:send, nil, :lambda)

      def on_block(node)
        # We're looking for
        # (block
        #   (send nil :lambda)
        #   ...)
        block_method, = *node

        if block_method == TARGET
          selector = block_method.loc.selector.source
          lambda_length = lambda_length(node)

          if selector != '->' && lambda_length == 0
            add_offence(:convention, block_method.loc.line, SINGLE_MSG)
          elsif selector == '->' && lambda_length > 0
            add_offence(:convention, block_method.loc.line, MULTI_MSG)
          end
        end

        super
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
