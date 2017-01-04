# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # A node extension for `while` nodes.
    class WhileNode < RuboCop::Node
      def keyword
        'while'
      end

      def do?
        loc.begin && loc.begin.is?('do')
      end

      def single_line_condition?
        loc.keyword.line == condition.source_range.line
      end

      def multiline_condition?
        !single_line_condition?
      end

      def condition
        node_parts[0]
      end

      def body
        node_parts[1]
      end

      def node_parts
        [*self]
      end
    end
  end
end
