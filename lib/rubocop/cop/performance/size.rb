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
          return unless eligible_node?(node)

          add_offense(node, location: :selector)
        end

        private

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'size') }
        end

        def eligible_node?(node)
          return false unless node.method?(:count) && !node.arguments?

          eligible_receiver?(node.receiver) && !allowed_parent?(node.parent)
        end

        def eligible_receiver?(node)
          return false unless node

          array?(node) || hash?(node)
        end

        def allowed_parent?(node)
          node && node.block_type?
        end

        def array?(node)
          _, constant = *node.receiver

          node.array_type? || constant == :Array || node.method_name == :to_a
        end

        def hash?(node)
          _, constant = *node.receiver

          node.hash_type? || constant == :Hash || node.method_name == :to_h
        end
      end
    end
  end
end
