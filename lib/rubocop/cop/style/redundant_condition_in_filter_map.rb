# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for redundant `filter_map` conditions where the condition equals the returned value.
      #
      # @example
      #   # bad
      #   items.filter_map { |foo| foo['bar'] if foo['bar'] }
      #   items.filter_map { it['foo'] if it['foo'] }
      #   items.filter_map { _1 if _1 }
      #
      #   # good
      #   items.filter_map { |foo| foo['bar'] }
      #   items.filter_map { it['foo'] }
      #   items.filter_map { _1 }
      class RedundantConditionInFilterMap < Base
        extend AutoCorrector

        MSG = 'Condition is redundant when equal to the value in `filter_map`.'

        # @!method filter_map_with_conditional?(node)
        def_node_matcher :filter_map_with_conditional?, <<~PATTERN
          {
            (block (call _ :filter_map) _ $(if $_ $_ nil?))
            (numblock (call _ :filter_map) _ $(if $_ $_ nil?))
            (itblock (call _ :filter_map) $(if $_ $_ nil?))
          }
        PATTERN

        def on_block(node)
          check_filter_map(node)
        end

        alias on_numblock on_block
        alias on_itblock on_block

        private

        def check_filter_map(node)
          filter_map_with_conditional?(node) do |if_node, condition, body|
            next unless condition == body

            add_offense(if_node) do |corrector|
              corrector.replace(if_node, condition.source)
            end
          end
        end
      end
    end
  end
end
