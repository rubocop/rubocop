# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks if the length a class exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class ClassLength < Cop
        include Util

        MSG = 'Class definition is too long. [%d/%d]'

        def on_class(node)
          check(node)
        end

        def max_length
          cop_config['Max']
        end

        def count_comments?
          cop_config['CountComments']
        end

        private

        def check(node)
          class_body_line_numbers = line_range(node).to_a[1...-1]

          target_line_numbers = class_body_line_numbers -
                                  line_numbers_of_inner_classes(node)

          class_length = target_line_numbers.reduce(0) do |length, line_number|
            source_line = processed_source[line_number]
            next length if source_line.blank?
            next length if !count_comments? && comment_line?(source_line)
            length + 1
          end

          if class_length > max_length
            message = sprintf(MSG, class_length, max_length)
            convention(node, :keyword, message)
          end
        end

        def line_numbers_of_inner_classes(node)
          line_numbers = Set.new

          on_node([:class, :module], node) do |inner_node|
            next if inner_node.eql?(node)
            line_range = line_range(inner_node)
            line_numbers.merge(line_range)
          end

          line_numbers.to_a
        end
      end
    end
  end
end
