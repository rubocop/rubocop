# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for uses of `map.to_h` or `collect.to_h` that could be
      # written with just `to_h` in Ruby >= 2.6.
      #
      # NOTE: `Style/HashTransformKeys` and `Style/HashTransformValues` will
      # also change this pattern if only hash keys or hash values are being
      # transformed.
      #
      # @safety
      #   This cop is unsafe, as it can produce false positives if the receiver
      #   is not an `Enumerable`.
      #
      # @example
      #   # bad
      #   something.map { |v| [v, v * 2] }.to_h
      #
      #   # good
      #   something.to_h { |v| [v, v * 2] }
      #
      #   # bad
      #   {foo: bar}.collect { |k, v| [k.to_s, v.do_something] }.to_h
      #
      #   # good
      #   {foo: bar}.to_h { |k, v| [k.to_s, v.do_something] }
      #
      class MapToHash < Base
        extend AutoCorrector
        extend TargetRubyVersion
        include RangeHelp

        minimum_target_ruby_version 2.6

        MSG = 'Pass a block to `to_h` instead of calling `%<method>s.to_h`.'
        RESTRICT_ON_SEND = %i[to_h].freeze

        # @!method map_to_h?(node)
        def_node_matcher :map_to_h?, <<~PATTERN
          $(send (block $(send _ {:map :collect}) ...) :to_h)
        PATTERN

        def on_send(node)
          return unless (to_h_node, map_node = map_to_h?(node))

          message = format(MSG, method: map_node.loc.selector.source)
          add_offense(map_node.loc.selector, message: message) do |corrector|
            # If the `to_h` call already has a block, do not auto-correct.
            next if to_h_node.block_node

            autocorrect(corrector, to_h_node, map_node)
          end
        end

        private

        def autocorrect(corrector, to_h, map)
          removal_range = range_between(to_h.loc.dot.begin_pos, to_h.loc.selector.end_pos)

          corrector.remove(range_with_surrounding_space(range: removal_range, side: :left))
          corrector.replace(map.loc.selector, 'to_h')
        end
      end
    end
  end
end
