# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicated keys in hash literals.
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
      class DuplicatedKey < Cop
        MSG = 'Duplicated key in hash literal.'.freeze

        def on_hash(node)
          keys = []

          node.each_pair do |key, _value|
            if keys.include?(key) && key.recursive_basic_literal?
              add_offense(key, :expression)
            end
            keys << key
          end
        end
      end
    end
  end
end
