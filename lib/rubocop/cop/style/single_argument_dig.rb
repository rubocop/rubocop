# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Sometimes using dig method ends up with just a single
      # argument. In such cases, dig should be replaced with [].
      #
      # @safety
      #   This cop is unsafe because it cannot be guaranteed that the receiver
      #   is an `Enumerable` or does not have a nonstandard implementation
      #   of `dig`.
      #
      # @example
      #   # bad
      #   { key: 'value' }.dig(:key)
      #   [1, 2, 3].dig(0)
      #
      #   # good
      #   { key: 'value' }[:key]
      #   [1, 2, 3][0]
      #
      #   # good
      #   { key1: { key2: 'value' } }.dig(:key1, :key2)
      #   [1, [2, [3]]].dig(1, 1)
      #
      #   # good
      #   keys = %i[key1 key2]
      #   { key1: { key2: 'value' } }.dig(*keys)
      #
      class SingleArgumentDig < Base
        extend AutoCorrector

        MSG = 'Use `%<receiver>s[%<argument>s]` instead of `%<original>s`.'
        RESTRICT_ON_SEND = %i[dig].freeze

        # @!method single_argument_dig?(node)
        def_node_matcher :single_argument_dig?, <<~PATTERN
          (send _ :dig $!splat)
        PATTERN

        def on_send(node)
          return unless node.receiver

          expression = single_argument_dig?(node)
          return unless expression

          receiver = node.receiver.source
          argument = expression.source

          message = format(MSG, receiver: receiver, argument: argument, original: node.source)
          add_offense(node, message: message) do |corrector|
            correct_access = "#{receiver}[#{argument}]"
            corrector.replace(node, correct_access)
          end
        end
      end
    end
  end
end
