# encoding: utf-8

module Rubocop
  module Cop
    # Handles adding and checking ignored nodes.
    module IgnoredNode
      def ignore_node(node)
        @ignored_nodes ||= []
        @ignored_nodes << node
      end

      def part_of_ignored_node?(node)
        return false unless @ignored_nodes
        expression = node.loc.expression
        @ignored_nodes.each do |ignored_node|
          if ignored_node.loc.expression.begin_pos <= expression.begin_pos &&
            ignored_node.loc.expression.end_pos >= expression.end_pos
            return true
          end
        end

        false
      end

      def ignored_node?(node)
        # Same object found in array?
        @ignored_nodes && @ignored_nodes.any? { |n| n.eql?(node) }
      end
    end
  end
end
