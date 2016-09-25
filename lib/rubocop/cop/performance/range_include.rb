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
      # Here is an example of a case where `Range#cover?` may not provide the
      # desired result:
      #
      #     ('a'..'z').cover?('yellow') # => true
      #
      class RangeInclude < Cop
        MSG = 'Use `Range#cover?` instead of `Range#include?`.'.freeze

        # TODO: If we traced out assignments of variables to their uses, we
        # might pick up on a few more instances of this issue
        # Right now, we only detect direct calls on a Range literal
        # (We don't even catch it if the Range is in double parens)

        def_node_matcher :range_include, <<-END
          (send {irange erange (begin {irange erange})} :include? ...)
        END

        def on_send(node)
          add_offense(node, :selector, MSG) if range_include(node)
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.selector, 'cover?') }
        end
      end
    end
  end
end
