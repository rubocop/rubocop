# encoding: utf-8
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
                              line_numbers_of_inner_thing(node, :module) -
                              line_numbers_of_inner_thing(node, :class)

        target_line_numbers.reduce(0) do |length, line_number|
          source_line = processed_source[line_number]
          next length if irrelevant_line(source_line)
          length + 1
        end
      end

      def line_numbers_of_inner_thing(node, type)
        line_numbers = Set.new

        node.each_descendant(type) do |inner_node|
          line_range = line_range(inner_node)
          line_numbers.merge(line_range)
        end

        line_numbers.to_a
      end
    end
  end
end
