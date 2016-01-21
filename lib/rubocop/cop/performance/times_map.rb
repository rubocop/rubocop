# encoding: utf-8
# frozen_string_literal: true

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
        MSG = 'Use `Array.new` with a block instead of `.times.%s`.'.freeze

        def on_send(node)
          check(node)
        end

        def on_block(node)
          check(node)
        end

        private

        def check(node)
          times_map_call(node) do |map_or_collect|
            add_offense(node, :expression, format(MSG, map_or_collect))
          end
        end

        def_node_matcher :times_map_call, <<-END
          {(block (send (send !nil :times) ${:map :collect}) ...)
           (send (send !nil :times) ${:map :collect} (block_pass ...))}
        END
      end
    end
  end
end
