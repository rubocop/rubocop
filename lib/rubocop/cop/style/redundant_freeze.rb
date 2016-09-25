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

        MSG = 'Freezing immutable objects is pointless.'.freeze

        def on_send(node)
          receiver, method_name, *args = *node

          return unless method_name == :freeze &&
                        args.empty? &&
                        immutable_literal?(receiver)

          add_offense(node, :expression)
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
            frozen_string_literals_enabled?(processed_source)
        end
      end
    end
  end
end
