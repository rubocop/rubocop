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
        MSG = 'Avoid multi-line chains of blocks.'

        def on_block(node)
          method, _args, _body = *node
          on_node(:send, method) do |send_node|
            receiver, _method_name, *_args = *send_node
            if receiver && receiver.type == :block
              # The begin and end could also be braces, but we call the
              # variables do... and end...
              do_kw_loc, end_kw_loc = receiver.loc.begin, receiver.loc.end

              if do_kw_loc.line != end_kw_loc.line
                range =
                  Parser::Source::Range.new(end_kw_loc.source_buffer,
                                            end_kw_loc.begin_pos,
                                            method.loc.expression.end_pos)
                add_offence(nil, range)
                # Done. If there are more blocks in the chain, they will be
                # found by subsequent calls to on_block.
                break
              end
            end
          end
        end
      end
    end
  end
end
