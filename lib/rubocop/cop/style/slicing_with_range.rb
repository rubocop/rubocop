# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that arrays are sliced with endless ranges instead of
      # `ary[start..-1]` on Ruby 2.6+.
      #
      # @safety
      #   This cop is unsafe because `x..-1` and `x..` are only guaranteed to
      #   be equivalent for `Array#[]`, and the cop cannot determine what class
      #   the receiver is.
      #
      #   For example:
      #   [source,ruby]
      #   ----
      #   sum = proc { |ary| ary.sum }
      #   sum[-3..-1] # => -6
      #   sum[-3..] # Hangs forever
      #   ----
      #
      # @example
      #   # bad
      #   items[1..-1]
      #
      #   # good
      #   items[1..]
      class SlicingWithRange < Base
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 2.6

        MSG = 'Prefer ary[n..] over ary[n..-1].'
        RESTRICT_ON_SEND = %i[[]].freeze

        # @!method range_till_minus_one?(node)
        def_node_matcher :range_till_minus_one?, '(irange !nil? (int -1))'

        def on_send(node)
          return unless node.arguments.count == 1
          return unless range_till_minus_one?(node.arguments.first)

          add_offense(node.first_argument) do |corrector|
            corrector.remove(node.first_argument.end)
          end
        end
      end
    end
  end
end
