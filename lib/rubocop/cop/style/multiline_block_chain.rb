# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for chaining of a block after another block that spans
      # multiple lines.
      #
      # @example
      #
      #   Thread.list.find_all do |t|
      #     t.alive?
      #   end.map do |t|
      #     t.object_id
      #   end
      class MultilineBlockChain < Cop
        MSG_1 = 'Avoid multi-line chains of blocks.'
        MSG_2 = 'Avoid chaining a method call on a multi-line block.'

        def on_block(node)
          method, _args, _body = *node
          on_node(:send, method) do |send_node|
            receiver, _method_name, *_args = *send_node
            if receiver && receiver.type == :block && check(receiver, method,
                                                            MSG_1)
              ignore_node(receiver) # Avoid double reporting.

              # Done. If there are more blocks in the chain, they will be
              # found by subsequent calls to on_block.
              break
            end
          end
        end

        def on_send(node)
          unless cop_config['AllowMethodCalledOnBlock']
            receiver, _method_name, *_args = *node
            if receiver && receiver.type == :block && !ignored_node?(receiver)
              check(receiver, node, MSG_2)
            end
          end
        end

        private

        # If there is an offence, adds the offence and returns true.
        def check(receiver, send_node, msg)
          # The begin and end could also be braces, but we call the variables
          # do... and end...
          do_kw_loc, end_kw_loc = receiver.loc.begin, receiver.loc.end

          return false if do_kw_loc.line == end_kw_loc.line

          range = Parser::Source::Range.new(end_kw_loc.source_buffer,
                                            end_kw_loc.begin_pos,
                                            send_node.loc.expression.end_pos)
          convention(nil, range, msg)
          true
        end
      end
    end
  end
end
