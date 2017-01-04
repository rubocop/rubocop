# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # A node extension for `until` nodes.
    class UntilNode < RuboCop::Node
      def keyword
        'until'
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
