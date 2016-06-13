# encoding: utf-8
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
      #   (0..10).each { }
      #
      #   @good
      #   10.times { }
      class EachForSimpleLoop < Cop
        def on_block(node)
          if bad_each_range(node)
            send_node, = *node
            range = send_node.receiver.source_range.join(send_node.loc.selector)
            add_offense(node, range, 'Use `Integer#times` for a simple loop ' \
                                     'which iterates a fixed number of times.')
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            min, max = bad_each_range(node)
            corrector.replace(node.children.first.source_range,
                              "#{max - min}.times")
          end
        end

        def_node_matcher :bad_each_range, <<-PATTERN
          (block (send (begin ({irange erange} (int $_) (int $_))) :each) (args) ...)
        PATTERN
      end
    end
  end
end
