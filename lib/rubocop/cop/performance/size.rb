# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop is used to identify usages of `count` on an
      # `Array` and `Hash` and change them to `size`.
      #
      # @example
      #   # bad
      #   [1, 2, 3].count
      #
      #   # bad
      #   {a: 1, b: 2, c: 3}.count
      #
      #   # good
      #   [1, 2, 3].size
      #
      #   # good
      #   {a: 1, b: 2, c: 3}.size
      #
      #   # good
      #   [1, 2, 3].count { |e| e > 2 }
      # TODO: Add advanced detection of variables that could
      # have been assigned to an array or a hash.
      class Size < Cop
        MSG = 'Use `size` instead of `count`.'.freeze

        def on_send(node)
          receiver, method, args = *node

          return if receiver.nil?
          return unless method == :count
          return unless array?(receiver) || hash?(receiver)
          return if node.parent && node.parent.block_type?
          return if args

          add_offense(node, node.loc.selector)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'size') }
        end

        private

        def array?(node)
          receiver, method = *node
          _, constant = *receiver

          node.array_type? || constant == :Array || method == :to_a
        end

        def hash?(node)
          receiver, method = *node
          _, constant = *receiver

          node.hash_type? || constant == :Hash || method == :to_h
        end
      end
    end
  end
end
