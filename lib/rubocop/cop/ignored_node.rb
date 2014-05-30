# encoding: utf-8

module RuboCop
  module Cop
    # Handles adding and checking ignored nodes.
    module IgnoredNode
      def ignore_node(node)
        ignored_nodes << node
      end

      def part_of_ignored_node?(node)
        expression = node.loc.expression
        ignored_nodes.any? do |ignored_node|
          ignored_node.loc.expression.begin_pos <= expression.begin_pos &&
            ignored_node.loc.expression.end_pos >= expression.end_pos
        end
      end

      def ignored_node?(node)
        # Same object found in array?
        ignored_nodes.any? { |n| n.equal?(node) }
      end

      private

      def ignored_nodes
        @ignored_nodes ||= []
      end
    end
  end
end
