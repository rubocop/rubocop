# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking length of classes and modules.
    module ClassishLength
      include CodeLength

      private

      def code_length(node)
        body_line_numbers = line_range(node).to_a[1...-1]

        target_line_numbers = body_line_numbers -
                              line_numbers_of_inner_nodes(node, :module, :class)

        target_line_numbers.reduce(0) do |length, line_number|
          source_line = processed_source[line_number]
          next length if irrelevant_line(source_line)

          length + 1
        end
      end

      def line_numbers_of_inner_nodes(node, *types)
        line_numbers = []

        #binding.pry
        #_each_child_node(node, *types) do |inner_node|
        #node.each_descendant(*types) do |inner_node|
        #_each_descendant(node, *types) do |inner_node|
        return [] if node.child_nodes.size == 1

        node.child_nodes[1].each_child_node(*types) do |inner_node|
          line_range = line_range(inner_node)
          #puts "=== #{inner_node}"
          #puts line_range
          line_numbers.concat(line_range.to_a)
          #puts "line numbers #{line_numbers}"
        end

        line_numbers.uniq
      end

      def _each_descendant(node, *types, &block)
        return to_enum(__method__, node, *types) unless block_given?

        _visit_descendants(node, types, &block)

        self
      end

      def _visit_descendants(node, types, &block)
        node.each_child_node do |child|
          yield child if types.empty? || types.include?(child.type)
          child.send(:visit_descendants, types, &block)
        end
      end
    end
  end
end
