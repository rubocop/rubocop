# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for loops which iterate a constant number of times,
      # using a Range literal and `#each`. This can be done more readably using
      # `Integer#times`.
      #
      # This check only applies if the block takes no parameters.
      #
      # @example
      #   # bad
      #   (1..5).each { }
      #
      #   # good
      #   5.times { }
      #
      # @example
      #   # bad
      #   (0...10).each {}
      #
      #   # good
      #   10.times {}
      class EachForSimpleLoop < Base
        extend AutoCorrector

        MSG = 'Use `Integer#times` for a simple loop which iterates a fixed number of times.'

        def on_block(node) # rubocop:disable InternalAffairs/NumblockHandler
          return unless offending_each_range(node)

          send_node = node.send_node

          range = send_node.receiver.source_range.join(send_node.loc.selector)

          add_offense(range) do |corrector|
            range_type, min, max = offending_each_range(node)

            max += 1 if range_type == :irange

            corrector.replace(node.send_node, "#{max - min}.times")
          end
        end

        private

        # @!method offending_each_range(node)
        def_node_matcher :offending_each_range, <<~PATTERN
          (block (send (begin (${irange erange} (int $_) (int $_))) :each) (args) ...)
        PATTERN
      end
    end
  end
end
