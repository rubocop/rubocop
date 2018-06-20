# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # This cop identifies uses of `Range#include?`, which iterates over each
      # item in a `Range` to see if a specified item is there. In contrast,
      # `Range#cover?` simply compares the target item with the beginning and
      # end points of the `Range`. In a great majority of cases, this is what
      # is wanted.
      #
      # @example
      #   # bad
      #   ('a'..'z').include?('b') # => true
      #
      #   # good
      #   ('a'..'z').cover?('b') # => true
      #
      #   # Example of a case where `Range#cover?` may not provide
      #   # the desired result:
      #
      #   ('a'..'z').cover?('yellow') # => true
      class RangeInclude < Cop
        MSG = 'Use `Range#cover?` instead of `Range#include?`.'.freeze

        # TODO: If we traced out assignments of variables to their uses, we
        # might pick up on a few more instances of this issue
        # Right now, we only detect direct calls on a Range literal
        # (We don't even catch it if the Range is in double parens)

        def_node_matcher :range_include, <<-PATTERN
          (send {irange erange (begin {irange erange})} :include? ...)
        PATTERN

        def on_send(node)
          return unless range_include(node)

          add_offense(node, location: :selector)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'cover?') }
        end
      end
    end
  end
end
