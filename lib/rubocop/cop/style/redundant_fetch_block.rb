# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop identifies places where `fetch(key) { value }`
      # can be replaced by `fetch(key, value)`.
      #
      # In such cases `fetch(key, value)` method is faster
      # than `fetch(key) { value }`.
      #
      # @example SafeForConstants: false (default)
      #   # bad
      #   hash.fetch(:key) { 5 }
      #   hash.fetch(:key) { true }
      #   hash.fetch(:key) { nil }
      #   array.fetch(5) { :value }
      #   ENV.fetch(:key) { 'value' }
      #
      #   # good
      #   hash.fetch(:key, 5)
      #   hash.fetch(:key, true)
      #   hash.fetch(:key, nil)
      #   array.fetch(5, :value)
      #   ENV.fetch(:key, 'value')
      #
      # @example SafeForConstants: true
      #   # bad
      #   ENV.fetch(:key) { VALUE }
      #
      #   # good
      #   ENV.fetch(:key, VALUE)
      #
      class RedundantFetchBlock < Cop
        include FrozenStringLiteral
        include RangeHelp

        MSG = 'Use `%<good>s` instead of `%<bad>s`.'

        def_node_matcher :redundant_fetch_block_candidate?, <<~PATTERN
          (block
            $(send _ :fetch _)
            (args)
            ${#basic_literal? const_type?})
        PATTERN

        def on_block(node)
          redundant_fetch_block_candidate?(node) do |send, body|
            return if body.const_type? && !check_for_constant?
            return if body.str_type? && !check_for_string?

            range = fetch_range(send, node)
            good = build_good_method(send, body)
            bad = build_bad_method(send, body)

            add_offense(
              node,
              location: range,
              message: format(MSG, good: good, bad: bad)
            )
          end
        end

        def autocorrect(node)
          redundant_fetch_block_candidate?(node) do |send, body|
            lambda do |corrector|
              receiver, _, key = send.children
              corrector.replace(node, "#{receiver.source}.fetch(#{key.source}, #{body.source})")
            end
          end
        end

        private

        def basic_literal?(node)
          node.basic_literal?
        end

        def fetch_range(send, node)
          range_between(send.loc.selector.begin_pos, node.loc.end.end_pos)
        end

        def build_good_method(send, body)
          key = send.children[2].source
          "fetch(#{key}, #{body.source})"
        end

        def build_bad_method(send, body)
          key = send.children[2].source
          "fetch(#{key}) { #{body.source} }"
        end

        def check_for_constant?
          cop_config['SafeForConstants']
        end

        def check_for_string?
          frozen_string_literals_enabled?
        end
      end
    end
  end
end
