# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer OR expressions over `Array#any?`.
      #
      # This cop only checks when the receiver of `any?` is an array literal.
      #
      # @safety
      #   Autocorrection is unsafe because `any?` returns a boolean while the
      #   OR expression returns the first truthy value.
      #
      #   It's also unsafe because OR expressions short-circuit; if any element
      #   is a method call with side effects, they may not run anymore with an
      #   OR expression.
      #
      #   [source,ruby]
      #   ----
      #   [foo, method_with_side_effects].any?
      #   # always evaluates `method_with_side_effects`
      #
      #   foo || method_with_side_effects
      #   # evaluates `method_with_side_effects` only if `foo` is falsey
      #   ----
      #
      # @example
      #
      #   # bad
      #   [foo, bar, baz].any?
      #
      #   # good
      #   (foo || bar || baz)
      #
      #   # good - arrays with splat arguments are ignored
      #   [foo, *bar].any?
      #
      class AnyPredicate < Base
        extend AutoCorrector

        MSG = 'Prefer an OR expression instead.'

        RESTRICT_ON_SEND = [:any?].freeze

        # @!method or_like_array_any?(node)
        def_node_matcher :or_like_array_any?, <<~PATTERN
          (send (array !splat_type?+) :any?)
        PATTERN

        def on_send(node)
          return unless or_like_array_any?(node)
          return if node.parent&.any_block_type?

          add_offense(node) do |corrector|
            array_item_sources = node.receiver.child_nodes.map(&:source)
            corrector.replace(node, "(#{array_item_sources.join(' || ')})")
          end
        end
      end
    end
  end
end
