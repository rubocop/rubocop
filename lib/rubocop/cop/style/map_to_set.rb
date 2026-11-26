# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Looks for uses of `map.to_set` or `collect.to_set` that could be
      # written with just `to_set`.
      #
      # @safety
      #   This cop is unsafe, as it can produce false positives if the receiver
      #   is not an `Enumerable`.
      #
      # @example
      #   # bad
      #   something.map { |i| i * 2 }.to_set
      #
      #   # good
      #   something.to_set { |i| i * 2 }
      #
      #   # bad
      #   [1, 2, 3].collect { |i| i.to_s }.to_set
      #
      #   # good
      #   [1, 2, 3].to_set { |i| i.to_s }
      #
      class MapToSet < Base
        extend AutoCorrector
        include ChainedCallRemoval

        MSG = 'Pass a block to `to_set` instead of calling `%<method>s.to_set`.'
        RESTRICT_ON_SEND = %i[to_set].freeze

        # @!method map_to_set?(node)
        def_node_matcher :map_to_set?, <<~PATTERN
          {
            $(call (any_block $(call _ {:map :collect}) ...) :to_set)
            $(call $(call _ {:map :collect} (block_pass sym)) :to_set)
          }
        PATTERN

        def on_send(node)
          return unless (to_set_node, map_node = map_to_set?(node))
          return if to_set_node.block_literal?
          return unless (removal_range = range_for_chained_call_removal(to_set_node))

          message = format(MSG, method: map_node.loc.selector.source)
          add_offense(map_node.loc.selector, message: message) do |corrector|
            corrector.remove(removal_range)
            corrector.replace(map_node.loc.selector, 'to_set')
          end
        end
        alias on_csend on_send
      end
    end
  end
end
