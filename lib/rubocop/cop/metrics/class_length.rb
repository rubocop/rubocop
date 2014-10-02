# encoding: utf-8

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length a class exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class ClassLength < Cop
        include CodeLength

        def on_class(node)
          check_code_length(node)
        end

        private

        def message(length, max_length)
          format('Class definition is too long. [%d/%d]', length, max_length)
        end

        def code_length(node)
          class_body_line_numbers = line_range(node).to_a[1...-1]

          target_line_numbers = class_body_line_numbers -
                                line_numbers_of_inner_classes(node)

          target_line_numbers.reduce(0) do |length, line_number|
            source_line = processed_source[line_number]
            next length if irrelevant_line(source_line)
            length + 1
          end
        end

        def line_numbers_of_inner_classes(node)
          line_numbers = Set.new

          node.each_descendant(:class, :module) do |inner_node|
            line_range = line_range(inner_node)
            line_numbers.merge(line_range)
          end

          line_numbers.to_a
        end
      end
    end
  end
end
