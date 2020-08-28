# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking for a line break before the first
    # element in a multi-line collection.
    module FirstElementLineBreak
      private

      def check_method_line_break(node, children)
        return if children.empty?

        return unless method_uses_parens?(node, children.first)

        check_children_line_break(node, children)
      end

      def method_uses_parens?(node, limit)
        source = node.source_range.source_line[0...limit.loc.column]
        /\s*\(\s*$/.match?(source)
      end

      def check_children_line_break(node, children, start = node)
        return if children.size < 2

        line = start.first_line

        min = first_by_line(children)
        return if line != min.first_line

        max = last_by_line(children)
        return if line == max.last_line

        add_offense(min) do |corrector|
          EmptyLineCorrector.insert_before(corrector, min)
        end
      end

      def first_by_line(nodes)
        nodes.min_by(&:first_line)
      end

      def last_by_line(nodes)
        nodes.max_by(&:last_line)
      end
    end
  end
end
