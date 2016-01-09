# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicated keys in hash literals.
      #
      # This cop mirrors a warning in Ruby 2.2.
      #
      # @example
      #   hash = { food: 'apple', food: 'orange' }
      class DuplicatedKey < Cop
        MSG = 'Duplicated key in hash literal.'.freeze

        LITERALS = [:sym, :str, :float, :int].freeze

        def on_hash(node)
          keys = []

          hash_pairs = *node
          hash_pairs.each do |pair|
            key, _value = *pair
            if keys.include?(key) && LITERALS.include?(key.type)
              add_offense(key, :expression)
            elsif keys.include?(key) && key.type == :array
              key.children.each do |child|
                return false unless LITERALS.include?(child.type)
              end
              add_offense(key, :expression)
            end
            keys << key
          end
        end
      end
    end
  end
end
