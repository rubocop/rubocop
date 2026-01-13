# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Looks for uses of `map.sum` or `collect.sum` that could be
      # written with just `sum`.
      #
      # @safety
      #   This cop is unsafe, as it can produce false positives if the receiver
      #   is not an `Enumerable`.
      #
      # @example
      #   # bad
      #   something.map { |i| i * 2 }.sum(0)
      #
      #   # good
      #   something.sum(0) { |i| i * 2 }
      #
      #   # bad
      #   [1, 2, 3].collect { |i| i.to_f }.sum(0.0)
      #
      #   # good
      #   [1, 2, 3].sum(0.0) { |i| i.to_f }
      #
      class MapToSum < Base
        extend AutoCorrector
        include RangeHelp

        MSG = 'Pass a block to `sum` instead of calling `%<method>s.sum`.'
        RESTRICT_ON_SEND = %i[sum].freeze

        # @!method map_to_sum?(node)
        def_node_matcher :map_to_sum?, <<~PATTERN
          {
            $(call (any_block $(call _ {:map :collect}) ...) :sum ...)
            $(call $(call _ {:map :collect} (block_pass sym)) :sum ...)
          }
        PATTERN

        def on_send(node)
          return unless (to_sum_node, map_node = map_to_sum?(node))
          return if to_sum_node.block_literal?

          message = format(MSG, method: map_node.loc.selector.source)
          add_offense(map_node.loc.selector, message: message) do |corrector|
            autocorrect(corrector, to_sum_node, map_node)
          end
        end
        alias on_csend on_send

        private

        def autocorrect(corrector, to_sum, map)
          sum_args = to_sum.arguments
          removal_range = sum_removal_range(to_sum)

          corrector.remove(range_with_surrounding_space(removal_range, side: :left))
          corrector.replace(map.loc.selector, 'sum')
          insert_sum_arguments(corrector, sum_args, map) if sum_args.any?
        end

        def sum_removal_range(to_sum)
          end_pos =
            if to_sum.loc.end
              to_sum.loc.end.end_pos
            elsif to_sum.arguments?
              arguments_range(to_sum).end_pos
            else
              to_sum.loc.selector.end_pos
            end

          range_between(to_sum.loc.dot.begin_pos, end_pos)
        end

        # rubocop:disable Metrics/AbcSize
        def insert_sum_arguments(corrector, sum_args, map)
          combined_args = (sum_args + map.arguments).map(&:source).join(', ')

          if map.arguments.any?
            corrector.replace(arguments_range(map), combined_args)
          elsif map.loc.begin
            corrector.replace(
              range_between(map.loc.begin.end_pos, map.loc.end.begin_pos),
              combined_args
            )
          else
            corrector.insert_after(map.loc.selector, "(#{combined_args})")
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
