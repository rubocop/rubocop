# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for methods called on a do...end block. The point of
      # this check is that it's easy to miss the call tacked on to the block
      # when reading code.
      #
      # @example
      #
      #   a do
      #     b
      #   end.c
      class MethodCalledOnDoEndBlock < Cop
        MSG = 'Avoid chaining a method call on a do...end block.'.freeze

        def on_block(node)
          method, _args, _body = *node
          # If the method that is chained on the do...end block is itself a
          # method with a block, we allow it. It's pretty safe to assume that
          # these calls are not missed by anyone reading code. We also want to
          # avoid double reporting of offenses checked by the
          # MultilineBlockChain cop.
          ignore_node(method)
        end

        def on_send(node)
          return if ignored_node?(node)

          receiver = node.receiver

          return unless receiver && receiver.block_type? &&
                        receiver.loc.end.is?('end')

          range = range_between(receiver.loc.end.begin_pos,
                                node.source_range.end_pos)

          add_offense(nil, range)
        end
      end
    end
  end
end
