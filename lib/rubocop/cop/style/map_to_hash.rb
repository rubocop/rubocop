# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Looks for uses of `map.to_h` or `collect.to_h` that could be
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
        include ChainedCallRemoval

        minimum_target_ruby_version 2.6

        MSG = 'Pass a block to `to_h` instead of calling `%<method>s%<dot>sto_h`.'
        RESTRICT_ON_SEND = %i[to_h].freeze

        # @!method map_to_h(node)
        def_node_matcher :map_to_h, <<~PATTERN
          {
            $(call (any_block $(call _ {:map :collect}) ...) :to_h)
            $(call $(call _ {:map :collect} (block_pass sym)) :to_h)
          }
        PATTERN

        # @!method destructuring_argument(node)
        def_node_matcher :destructuring_argument, <<~PATTERN
          (args $(mlhs (arg _)+))
        PATTERN

        def on_send(node)
          return unless (to_h_node, map_node = map_to_h(node))
          return if to_h_node.block_literal?
          return unless (removal_range = range_for_chained_call_removal(to_h_node))

          message = format(MSG, method: map_node.loc.selector.source, dot: to_h_node.loc.dot.source)
          add_offense(map_node.loc.selector, message: message) do |corrector|
            corrector.remove(removal_range)
            autocorrect(corrector, to_h_node, map_node)
          end
        end
        alias on_csend on_send

        private

        # rubocop:disable-next Metrics/AbcSize
        def autocorrect(corrector, to_h, map)
          if (map_dot = map.loc.dot)
            corrector.replace(map_dot, to_h.loc.dot.source)
          end
          corrector.replace(map.loc.selector, 'to_h')

          return unless map.parent.block_type?

          if (argument = destructuring_argument(map.parent.arguments))
            corrector.replace(argument, argument.source[1..-2])
          end
        end
      end
    end
  end
end
