# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for duplicated keys in hash literals.
      #
      # This cop mirrors a warning in Ruby 2.2.
      #
      # @example
      #
      #   # bad
      #
      #   hash = { food: 'apple', food: 'orange' }
      #
      # @example
      #
      #   # good
      #
      #   hash = { food: 'apple', other_food: 'orange' }
      class DuplicateHashKey < Base
        include Duplication

        MSG = 'Duplicated key in hash literal.'

        def on_hash(node)
          keys = node.keys.select(&:recursive_basic_literal?)

          return unless duplicates?(keys)

          consecutive_duplicates(keys).each { |key| add_offense(key) }
        end
      end
    end
  end
end
