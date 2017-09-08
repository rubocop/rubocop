# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Checks for redundant `location` argument to `#add_offense`. `location`
      # argument has a default value of `:expression` and this method will
      # automatically use it.
      #
      # @example
      #
      #   # bad
      #   add_offense(node, :expression)
      #
      #   # good
      #   add_offense(node)
      #   add_offense(node, :selector)
      #   add_offense(node, :expression, 'message')
      #
      class RedundantLocationArgument < Cop
        MSG = 'Redundant location argument to `#add_offense`.'.freeze

        def_node_matcher :node_type_check, <<-PATTERN
          (send nil :add_offense _ (sym :expression))
        PATTERN

        def on_send(node)
          node_type_check(node) do
            add_offense(node.last_argument)
          end
        end

        def autocorrect(node)
          first, second = node.parent.arguments

          range = range_between(
            first.loc.expression.end_pos,
            second.loc.expression.end_pos
          )

          ->(corrector) { corrector.remove(range) }
        end
      end
    end
  end
end
