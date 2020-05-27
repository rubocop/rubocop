# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that arrays are sliced with endless ranges instead of
      # `ary[start..-1]` on Ruby 2.6+.
      #
      # @example
      #   # bad
      #   items[1..-1]
      #
      #   # good
      #   items[1..]
      class SlicingWithRange < Cop
        extend TargetRubyVersion

        minimum_target_ruby_version 2.6

        MSG = 'Prefer ary[n..] over ary[n..-1].'

        def_node_matcher :range_till_minus_one?, '(irange !nil? (int -1))'

        def on_send(node)
          return unless node.method?(:[]) && node.arguments.count == 1
          return unless range_till_minus_one?(node.arguments.first)

          add_offense(node.arguments.first)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.end)
          end
        end
      end
    end
  end
end
