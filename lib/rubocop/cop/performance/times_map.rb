# encoding: utf-8

module RuboCop
  module Cop
    module Performance
      # This cop checks for .times.map calls.
      # In most cases such calls can be replaced
      # with an explicit array creation.
      #
      # @example
      #
      #   @bad
      #   9.times.map do |i|
      #     i.to_s
      #   end
      #
      #   @good
      #   Array.new(9) do |i|
      #     i.to_s
      #   end
      class TimesMap < Cop
        MSG = 'Use `Array.new` with a block instead of `.times.%s`.'

        def on_send(node)
          check(node)
        end

        def on_block(node)
          check(node)
        end

        private

        def check(node)
          map_or_collect = times_map_call(node)
          if map_or_collect
            add_offense(node, :expression, format(MSG, map_or_collect))
          end
        end

        def_node_matcher :times_map_call, <<-END
          {(block (send (send _ :times) ${:map :collect}) ...)
           (send (send _ :times) ${:map :collect} (block_pass ...))}
        END
      end
    end
  end
end
