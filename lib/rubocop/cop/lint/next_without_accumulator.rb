# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Don't omit the accumulator when calling `next` in a `reduce` block.
      #
      # @example
      #
      #   # bad
      #
      #   result = (1..4).reduce(0) do |acc, i|
      #     next if i.odd?
      #     acc + i
      #   end
      #
      # @example
      #
      #   # good
      #
      #   result = (1..4).reduce(0) do |acc, i|
      #     next acc if i.odd?
      #     acc + i
      #   end
      class NextWithoutAccumulator < Base
        MSG = 'Use `next` with an accumulator argument in a `reduce`.'

        def on_block(node)
          on_block_body_of_reduce(node) do |body|
            void_next = body.each_node(:next).find do |n|
              n.children.empty? && parent_block_node(n) == node
            end

            add_offense(void_next) if void_next
          end
        end

        def on_numblock(node)
          on_numblock_body_of_reduce(node) do |body|
            void_next = body.each_node(:next).find do |n|
              n.children.empty? && parent_numblock_node(n) == node
            end

            add_offense(void_next) if void_next
          end
        end

        private

        # @!method on_block_body_of_reduce(node)
        def_node_matcher :on_block_body_of_reduce, <<~PATTERN
          (block (send _recv {:reduce :inject} !sym) _blockargs $(begin ...))
        PATTERN

        # @!method on_numblock_body_of_reduce(node)
        def_node_matcher :on_numblock_body_of_reduce, <<~PATTERN
          (numblock (send _recv {:reduce :inject} !sym) _argscount $(begin ...))
        PATTERN

        def parent_block_node(node)
          node.each_ancestor(:block).first
        end

        def parent_numblock_node(node)
          node.each_ancestor(:numblock).first
        end
      end
    end
  end
end
