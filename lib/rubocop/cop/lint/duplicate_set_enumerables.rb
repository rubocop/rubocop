# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for duplicate enumerables in a Set.
      # This cop detects arguments and use them to check duplacity.
      #
      # @example
      #
      #   # bad
      #   Set.new[:food, :food]
      #
      #   # good
      #   Set.new[:food, :other_food]
      #
      #   # bad
      #   Set.new['food', 'food']
      #
      #   # good
      #   Set.new['food', 'other_food']
      #
      #   # bad
      #   Set.new[1, 1]
      #
      #   # good
      #   Set.new[1, 2]
      #
      #   # bad
      #   Set.new[true, true]
      #
      #   # good
      #   Set.new[true, false]
      class DuplicateSetEnumerables < Base
        include Duplication

        MSG = 'Duplicate enumerables found in Set.'

        def on_send(node)
          return unless duplicates?(node.arguments)

          duplicates(node.arguments).each do |duplicate|
            add_offense(duplicate)
          end
        end
      end
    end
  end
end
