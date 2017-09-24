# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for loops which iterate a constant number of times,
      # using a Range literal and `#each`. This can be done more readably using
      # `Integer#times`.
      #
      # This check only applies if the block takes no parameters.
      #
      # @example
      #   @bad
      #   (1..5).each { }
      #
      #   @good
      #   5.times { }
      #
      # @example
      #   @bad
      #   (0...10).each {}
      #
      #   @good
      #   10.times {}
      class EachForSimpleLoop < Cop
        MSG = 'Use `Integer#times` for a simple loop which iterates a fixed ' \
              'number of times.'.freeze

        def on_block(node)
          return unless offending_each_range(node)

          send_node = node.send_node

          range = send_node.receiver.source_range.join(send_node.loc.selector)

          add_offense(node, location: range)
        end

        private

        def autocorrect(node)
          lambda do |corrector|
            range_type, min, max = offending_each_range(node)

            max += 1 if range_type == :irange

            corrector.replace(node.children.first.source_range,
                              "#{max - min}.times")
          end
        end

        def_node_matcher :offending_each_range, <<-PATTERN
          (block (send (begin (${irange erange} (int $_) (int $_))) :each) (args) ...)
        PATTERN
      end
    end
  end
end
