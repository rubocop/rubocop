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
      class RedundantFreeze < Base
        extend AutoCorrector
        include FrozenStringLiteral

        MSG = 'Do not freeze immutable objects, as freezing them has no ' \
              'effect.'
        RESTRICT_ON_SEND = %i[freeze].freeze

        def on_send(node)
          return unless node.receiver &&
                        (immutable_literal?(node.receiver) ||
                         operation_produces_immutable_object?(node.receiver))

          add_offense(node) do |corrector|
            corrector.remove(node.loc.dot)
            corrector.remove(node.loc.selector)
          end
        end

        private

        def immutable_literal?(node)
          node = strip_parenthesis(node)

          return true if node.immutable_literal?

          FROZEN_STRING_LITERAL_TYPES.include?(node.type) &&
            frozen_string_literals_enabled?
        end

        def strip_parenthesis(node)
          if node.begin_type? && node.children.first
            node.children.first
          else
            node
          end
        end

        def_node_matcher :operation_produces_immutable_object?, <<~PATTERN
          {
            (begin (send {float int} {:+ :- :* :** :/ :% :<<} _))
            (begin (send !(str _) {:+ :- :* :** :/ :%} {float int}))
            (begin (send _ {:== :=== :!= :<= :>= :< :>} _))
            (send (const {nil? cbase} :ENV) :[] _)
            (send _ {:count :length :size} ...)
            (block (send _ {:count :length :size} ...) ...)
          }
        PATTERN
      end
    end
  end
end
