# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop check for uses of `Object#freeze` on immutable objects.
      #
      # NOTE: Regexp and Range literals are frozen objects since Ruby 3.0.
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

        MSG = 'Do not freeze immutable objects, as freezing them has no effect.'
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

          return true if FROZEN_STRING_LITERAL_TYPES.include?(node.type) &&
                         frozen_string_literals_enabled?

          target_ruby_version >= 3.0 && (node.regexp_type? || node.range_type?)
        end

        def strip_parenthesis(node)
          if node.begin_type? && node.children.first
            node.children.first
          else
            node
          end
        end

        # @!method operation_produces_immutable_object?(node)
        def_node_matcher :operation_produces_immutable_object?, <<~PATTERN
          {
            (begin (send {float int} {:+ :- :* :** :/ :% :<<} _))
            (begin (send !{(str _) array} {:+ :- :* :** :/ :%} {float int}))
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
