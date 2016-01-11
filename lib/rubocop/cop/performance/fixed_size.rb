# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Do not compute the size of statically sized objects.
      class FixedSize < Cop
        MSG = 'Do not compute the size of statically sized objects.'.freeze
        COUNTERS = [:count, :length, :size].freeze
        STATIC_SIZED_TYPES = [:array, :hash, :str, :sym].freeze

        def on_send(node)
          variable, method, arg = *node
          return unless variable
          return unless COUNTERS.include?(method)
          return unless STATIC_SIZED_TYPES.include?(variable.type)
          return if contains_splat?(variable)
          return if contains_double_splat?(variable)
          return if string_argument?(arg)
          if node.parent
            return if node.parent.casgn_type? || node.parent.block_type?
          end
          add_offense(node, :expression)
        end

        private

        def contains_splat?(node)
          return unless node.array_type?

          node.children.any? do |child|
            child.respond_to?(:splat_type?) && child.splat_type?
          end
        end

        def contains_double_splat?(node)
          return unless node.hash_type?

          node.children.any? do |child|
            child.respond_to?(:kwsplat_type?) && child.kwsplat_type?
          end
        end

        def string_argument?(node)
          node && !node.str_type?
        end
      end
    end
  end
end
