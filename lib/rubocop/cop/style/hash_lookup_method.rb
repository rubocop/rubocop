# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Enforces the use of either `Hash#[]` or `Hash#fetch` for hash lookup.
      #
      # This cop can be configured to prefer either bracket-style (`[]`)
      # or fetch-style lookup. It is disabled by default.
      #
      # When enforcing `fetch` style, only single-argument bracket access is flagged.
      # When enforcing `brackets` style, only `fetch` calls with a single key
      # argument are flagged (not those with default values or blocks).
      #
      # @safety
      #   This cop is unsafe because `Hash#[]` and `Hash#fetch` have different
      #   semantics. `Hash#[]` returns `nil` for missing keys, while `Hash#fetch`
      #   raises a `KeyError`. Replacing one with the other can change program
      #   behavior in cases where the key is missing.
      #
      #   Additionally, it cannot be guaranteed that the receiver is a `Hash`
      #   or responds to the replacement method.
      #
      # @example EnforcedStyle: brackets (default)
      #   # bad
      #   hash.fetch(key)
      #
      #   # good
      #   hash[key]
      #
      #   # good - fetch with default value is allowed
      #   hash.fetch(key, default)
      #
      #   # good - fetch with block is allowed
      #   hash.fetch(key) { default }
      #
      #   # good - `ENV.fetch` is left to `Style/FetchEnvVar` when it is enabled
      #   ENV.fetch(key)
      #
      # @example EnforcedStyle: fetch
      #   # bad
      #   hash[key]
      #
      #   # good
      #   hash.fetch(key)
      #
      # @example AllowedReceivers: ['Rails.cache']
      #   # good
      #   Rails.cache.fetch(name, options) { block }
      #
      class HashLookupMethod < Base
        include ConfigurableEnforcedStyle
        include AllowedReceivers
        extend AutoCorrector

        BRACKET_MSG = 'Use `Hash#[]` instead of `Hash#fetch`.'
        FETCH_MSG = 'Use `Hash#fetch` instead of `Hash#[]`.'

        RESTRICT_ON_SEND = %i[[] fetch].freeze

        # @!method env_const?(node)
        def_node_matcher :env_const?, '(const {nil? cbase} :ENV)'

        def on_send(node)
          return if (receiver = node.receiver) && allowed_receiver?(receiver)
          return if part_of_ignored_node?(node)

          if offense_for_brackets?(node)
            ignore_node(node.first_argument)
            add_offense(node.loc.selector, message: BRACKET_MSG) do |corrector|
              correct_fetch_to_brackets(corrector, node)
            end
          elsif offense_for_fetch?(node)
            ignore_node(node.first_argument)
            add_offense(node, message: FETCH_MSG) do |corrector|
              correct_brackets_to_fetch(corrector, node)
            end
          end
        end
        alias on_csend on_send

        private

        def offense_for_brackets?(node)
          return false if style != :brackets || !node.receiver
          return false if !node.method?(:fetch) || !node.arguments.one?
          return false if node.block_literal? || node.csend_type?

          !exempt_from_brackets?(node)
        end

        def exempt_from_brackets?(node)
          comment_before_dot?(node) || env_fetch_preferred?(node.receiver)
        end

        def comment_before_dot?(node)
          processed_source.contains_comment?(node.receiver.source_range.end.join(node.loc.dot))
        end

        def env_fetch_preferred?(receiver)
          env_const?(receiver) && processed_source.registry.enabled?(Style::FetchEnvVar, config)
        end

        def offense_for_fetch?(node)
          style == :fetch && node.method?(:[]) && node.arguments.one? &&
            !compound_assignment_target?(node)
        end

        def compound_assignment_target?(node)
          node.parent&.type?(:op_asgn, :or_asgn, :and_asgn) && node.parent.children.first == node
        end

        def correct_fetch_to_brackets(corrector, node)
          key = node.first_argument.source

          corrector.replace(node.receiver.source_range.end.join(node.source_range.end), "[#{key}]")
        end

        def correct_brackets_to_fetch(corrector, node)
          key = node.first_argument.source
          replacement = node.loc.dot ? "fetch(#{key})" : ".fetch(#{key})"

          corrector.replace(node.loc.selector.join(node.source_range.end), replacement)
        end
      end
    end
  end
end
