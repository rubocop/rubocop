# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Performance
      # Do not compute the size of statically sized objects.
      class FixedSize < Cop
        MSG = 'Do not compute the size of statically sized objects.'.freeze

        def_node_matcher :counter, <<-MATCHER
          (send ${array hash str sym} {:count :length :size} $...)
        MATCHER

        def on_send(node)
          counter(node) do |variable, arg|
            return if contains_splat?(variable)
            return if contains_double_splat?(variable)
            return if !arg.nil? && string_argument?(arg.first)
            if node.parent
              return if node.parent.casgn_type? || node.parent.block_type?
            end

            add_offense(node, :expression)
          end
        end

        private

        def contains_splat?(node)
          return unless node.array_type?

          node.each_child_node(:splat).any?
        end

        def contains_double_splat?(node)
          return unless node.hash_type?

          node.each_child_node(:kwsplat).any?
        end

        def string_argument?(node)
          node && !node.str_type?
        end
      end
    end
  end
end
