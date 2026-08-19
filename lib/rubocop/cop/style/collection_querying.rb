# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Prefer `Enumerable` predicate methods over expressions with `count`.
      #
      # The cop checks calls to `count` without arguments, or with a
      # block. It doesn't register offenses for `count` with a positional
      # argument because its behavior differs from predicate methods (`count`
      # matches the argument using `==`, while `any?`, `none?` and `one?` use
      # `===`).
      #
      # NOTE: This cop doesn't check `length` and `size` methods because they
      # would yield false positives. For example, `String` implements `length`
      # and `size`, but it doesn't include `Enumerable`.
      #
      # When `count` is used without a block, it measures the collection's
      # size, so the offense is corrected to `empty?` or `!empty?`. The
      # predicate methods `any?`, `none?` and `one?` test element truthiness
      # instead and would return different results for collections with falsey
      # elements (e.g. `[false].count.zero?` is `false`, but `[false].none?`
      # is `true`). For the same reason, `count == 1` and `count > 1` without
      # a block are not flagged.
      #
      # @safety
      #   The cop is unsafe because receiver might not include `Enumerable`, or
      #   it has nonstandard implementation of `count` or any replacement
      #   methods.
      #
      #   Autocorrection is unsafe when replacement methods don't iterate over
      #   every element in collection and the given block runs side effects:
      #
      #   [source,ruby]
      #   ----
      #   x.count(&:method_with_side_effects).positive?
      #   # calls `method_with_side_effects` on every element
      #
      #   x.any?(&:method_with_side_effects)
      #   # calls `method_with_side_effects` until first element returns a truthy value
      #   ----
      #
      # @example
      #
      #   # bad
      #   x.count.positive?
      #   x.count > 0
      #   x.count != 0
      #
      #   # good
      #   !x.empty?
      #
      #   # bad
      #   x.count(&:foo?).positive?
      #   x.count { |item| item.foo? }.positive?
      #
      #   # good
      #   x.any?(&:foo?)
      #   x.any? { |item| item.foo? }
      #
      #   # bad
      #   x.count.zero?
      #   x.count == 0
      #
      #   # good
      #   x.empty?
      #
      #   # bad
      #   x.count(&:foo?).zero?
      #   x.count(&:foo?) == 0
      #
      #   # good
      #   x.none?(&:foo?)
      #
      #   # bad
      #   x.count(&:foo?) == 1
      #
      #   # good
      #   x.one?(&:foo?)
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: false (default)
      #
      #   # good
      #   x.count(&:foo?) > 1
      #
      # @example AllCops:ActiveSupportExtensionsEnabled: true
      #
      #   # bad
      #   x.count(&:foo?) > 1
      #
      #   # good
      #   x.many?(&:foo?)
      #
      class CollectionQuerying < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Use `%<prefer>s` instead.'

        RESTRICT_ON_SEND = %i[positive? > != zero? ==].freeze

        REPLACEMENTS = {
          [:positive?, nil] => 'any?',
          [:>, 0] => 'any?',
          [:!=, 0] => 'any?',
          [:zero?, nil] => 'none?',
          [:==, 0] => 'none?',
          [:==, 1] => 'one?',
          [:>, 1] => 'many?'
        }.freeze

        NO_BLOCK_REPLACEMENTS = {
          [:positive?, nil] => '!empty?',
          [:>, 0] => '!empty?',
          [:!=, 0] => '!empty?',
          [:zero?, nil] => 'empty?',
          [:==, 0] => 'empty?'
        }.freeze

        # @!method count_predicate(node)
        def_node_matcher :count_predicate, <<~PATTERN
          (send
            {
              (any_block $(call !nil? :count) _ _)
              $(call !nil? :count (block-pass _)?)
            }
            {
              :positive? |
              :> (int 0) |
              :!= (int 0) |
              :zero? |
              :== (int 0) |
              :== (int 1) |
              :> (int 1)
            })
        PATTERN

        def on_send(node)
          return unless (count_node = count_predicate(node))

          replacement = replacement_method(node, count_node)

          return unless replacement_supported?(node, replacement)

          offense_range = count_node.loc.selector.join(node.source_range.end)
          add_offense(offense_range,
                      message: format(MSG, prefer: replacement)) do |corrector|
            autocorrect(corrector, node, count_node, replacement)
          end
        end

        private

        def autocorrect(corrector, node, count_node, replacement)
          if replacement.start_with?('!')
            corrector.insert_before(count_node, '!')
            corrector.replace(count_node.loc.selector, 'empty?')
          else
            corrector.replace(count_node.loc.selector, replacement)
          end

          corrector.remove(removal_range(node))
        end

        def replacement_method(node, count_node)
          key = [node.method_name, node.first_argument&.value]
          return REPLACEMENTS.fetch(key) if block_given_to_count?(count_node)

          NO_BLOCK_REPLACEMENTS[key]
        end

        def block_given_to_count?(count_node)
          count_node.parent&.any_block_type? || count_node.last_argument&.block_pass_type?
        end

        def replacement_supported?(node, replacement)
          return false unless replacement
          return false if replacement == 'many?' && !active_support_extensions_enabled?

          !(replacement.start_with?('!') && receiver_of_call?(node))
        end

        def receiver_of_call?(node)
          node.parent&.call_type? && node.parent.receiver == node
        end

        def removal_range(node)
          range = (node.loc.dot || node.loc.selector).join(node.source_range.end)

          range_with_surrounding_space(range, side: :left)
        end
      end
    end
  end
end
