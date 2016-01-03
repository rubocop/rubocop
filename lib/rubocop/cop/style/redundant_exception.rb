# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for RuntimeError as the argument of raise/fail.
      #
      # Currently it checks for code like this:
      #
      # @example
      #
      #   raise RuntimeError, 'message'
      class RedundantException < Cop
        MSG = 'Redundant `RuntimeError` argument can be removed.'.freeze

        TARGET_NODE = s(:const, nil, :RuntimeError)

        def on_send(node)
          return unless node.command?(:raise) || node.command?(:fail)

          _receiver, _selector, *args = *node

          return unless args.size == 2

          first_arg, = *args

          add_offense(first_arg, :expression) if first_arg == TARGET_NODE
        end

        # switch `raise RuntimeError, 'message'` to `raise 'message'`
        def autocorrect(node)
          start_range = node.source_range.begin
          no_comma = range_with_surrounding_comma(node.source_range.end, :right)
          comma_range = start_range.join(no_comma)
          final_range = range_with_surrounding_space(comma_range, :right)
          ->(corrector) { corrector.replace(final_range, '') }
        end
      end
    end
  end
end
