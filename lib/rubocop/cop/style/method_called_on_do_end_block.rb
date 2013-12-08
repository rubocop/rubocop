# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for methods called on a do...end block. The point of
      # this check is that it's easy to miss the call tacked on to the block
      # when reading code.
      #
      # @example
      #
      # a do
      #   b
      # end.c
      class MethodCalledOnDoEndBlock < Cop
        MSG = 'Avoid chaining a method call on a do...end block.'

        def on_block(node)
          method, _args, _body = *node
          # If the method that is chained on the do...end block is itself a
          # method with a block, we allow it. It's pretty safe to assume that
          # these calls are not missed by anyone reading code. We also want to
          # avoid double reporting of offences checked by the
          # MultilineBlockChain cop.
          ignore_node(method)
        end

        def on_send(node)
          return if ignored_node?(node)
          receiver, _method_name, *_args = *node
          if receiver && receiver.type == :block && receiver.loc.end.is?('end')
            range = Parser::Source::Range.new(receiver.loc.end.source_buffer,
                                              receiver.loc.end.begin_pos,
                                              node.loc.expression.end_pos)
            add_offence(nil, range)
          end
        end
      end
    end
  end
end
