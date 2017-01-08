# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop check for uses of Object#freeze on immutable objects.
      #
      # @example
      #   # bad
      #   CONST = 1.freeze
      #
      #   # good
      #   CONST = 1
      class RedundantFreeze < Cop
        include FrozenStringLiteral

        MSG = 'Do not freeze immutable objects, as freezing them has no ' \
              'effect.'.freeze

        def_node_matcher :freezing?, '(send $_ :freeze)'

        def on_send(node)
          freezing?(node) do |receiver|
            return unless immutable_literal?(receiver)
            add_offense(node, :expression)
          end
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(node.loc.dot)
            corrector.remove(node.loc.selector)
          end
        end

        private

        def immutable_literal?(node)
          return false unless node
          return true if node.immutable_literal?
          FROZEN_STRING_LITERAL_TYPES.include?(node.type) &&
            frozen_string_literals_enabled?
        end
      end
    end
  end
end
