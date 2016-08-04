# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking documentation.
    module DocumentationComment
      extend NodePattern::Macros

      def_node_matcher :constant_definition?, '{class module casgn}'

      private

      def associated_comment?(node)
        preceding_lines = preceding_lines(node)

        return false unless preceding_comment?(node, preceding_lines.last)

        preceding_lines.any? do |comment|
          !annotation?(comment) && !interpreter_directive_comment?(comment)
        end
      end

      def preceding_comment?(node, line)
        line && preceed?(line, node) &&
          comment_line?(line.loc.expression.source)
      end

      def preceding_lines(node)
        processed_source.ast_with_comments[node].select do |line|
          line.loc.line < node.loc.line
        end
      end

      def interpreter_directive_comment?(comment)
        comment.text =~ /^#\s*(frozen_string_literal|encoding):/
      end
    end
  end
end
