# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks that arrays are sliced with endless ranges instead of
      # `ary[start..-1]` on Ruby 2.6+.
      #
      # @safety
      #   This cop is unsafe because `x..-1` and `x..` are only guaranteed to
      #   be equivalent for `Array#[]`, `String#[]`, and the cop cannot determine what class
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

        MSG = 'Prefer `%<prefer>s` over `%<current>s`.'
        RESTRICT_ON_SEND = %i[[]].freeze

        # @!method range_till_minus_one?(node)
        def_node_matcher :range_till_minus_one?, '(irange !nil? (int -1))'

        def on_send(node)
          return unless node.arguments.one?

          range_node = node.first_argument
          return unless range_till_minus_one?(range_node)

          prefer = preferred_method(range_node)
          selector = node.loc.selector
          message = format(MSG, prefer: prefer, current: selector.source)

          add_offense(selector, message: message) do |corrector|
            corrector.remove(range_node.end)
          end
        end

        private

        def preferred_method(range_node)
          "[#{range_node.begin.source}#{range_node.loc.operator.source}]"
        end
      end
    end
  end
end
