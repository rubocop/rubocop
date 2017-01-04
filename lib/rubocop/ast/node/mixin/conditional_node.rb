# frozen_string_literal: true

module RuboCop
  module AST
    # Common functionality for nodes that have conditions:
    # `if`, `while`, `until`, `case`
    module ConditionalNode
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
    end
  end
end
