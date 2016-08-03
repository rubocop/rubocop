# encoding: utf-8
# frozen_string_literal: true

module RuboCop
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
        MSG = 'Avoid multi-line chains of blocks.'.freeze

        def on_block(node)
          method, _args, _body = *node
          method.each_node(:send) do |send_node|
            receiver, _method_name, *_args = *send_node
            next unless receiver && receiver.block_type?

            # The begin and end could also be braces, but we call the
            # variables do... and end...
            do_kw_loc = receiver.loc.begin
            end_kw_loc = receiver.loc.end
            next if do_kw_loc.line == end_kw_loc.line

            range =
              Parser::Source::Range.new(end_kw_loc.source_buffer,
                                        end_kw_loc.begin_pos,
                                        method.source_range.end_pos)
            add_offense(nil, range)
            # Done. If there are more blocks in the chain, they will be
            # found by subsequent calls to on_block.
            break
          end
        end
      end
    end
  end
end
