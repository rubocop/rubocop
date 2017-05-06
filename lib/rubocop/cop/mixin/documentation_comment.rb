# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking documentation.
    module DocumentationComment
      extend NodePattern::Macros
      include Style::AnnotationComment

      def_node_matcher :constant_definition?, '{class module casgn}'

      private

      def documentation_comment?(node)
        preceding_lines = preceding_lines(node)

        return false unless preceding_comment?(node, preceding_lines.last)

        preceding_lines.any? do |comment|
          !annotation?(comment) &&
            !interpreter_directive_comment?(comment) &&
            !rubocop_directive_comment?(comment)
        end
      end

      def preceding_comment?(n1, n2)
        n1 && n2 && preceed?(n2, n1) &&
          comment_line?(n2.loc.expression.source)
      end

      def preceding_lines(node)
        processed_source.ast_with_comments[node].select do |line|
          line.loc.line < node.loc.line
        end
      end

      def interpreter_directive_comment?(comment)
        comment.text =~ /^#\s*(frozen_string_literal|encoding):/
      end

      def rubocop_directive_comment?(comment)
        CommentDirective.from_comment(comment) != nil
      end
    end
  end
end
