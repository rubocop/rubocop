# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks that `unless` is not used with multiple conditions.
      # In general, using multiple conditions with `unless` reduces readability.
      #
      # @example
      #   # bad
      #   unless foo && bar
      #     something
      #   end
      #
      #   # bad
      #   unless foo || bar
      #     something
      #   end
      #
      #   # good
      #   if !foo || !bar
      #     something
      #   end
      #
      #   # good
      #   if !foo && !bar
      #     something
      #   end
      class UnlessMultipleConditions < Cop
        MSG = 'Avoid using `unless` with multiple conditions.'.freeze

        def on_if(node)
          return unless node.unless?

          add_offense(node.condition) if node.condition.and_type? ||
                                         node.condition.or_type?
        end
      end
    end
  end
end
