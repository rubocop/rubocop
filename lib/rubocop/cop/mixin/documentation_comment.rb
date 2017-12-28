# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking documentation.
    module DocumentationComment
      extend NodePattern::Macros
      include Style::AnnotationComment

      private

      def_node_matcher :constant_definition?, '{class module casgn}'

      def documentation_comment?(node)
        preceding_lines = preceding_lines(node)

        return false unless preceding_comment?(node, preceding_lines.last)

        preceding_lines.any? do |comment|
          !annotation?(comment) &&
            !interpreter_directive_comment?(comment) &&
            !rubocop_directive_comment?(comment)
        end
      end

      # The args node1 & node2 may represent a RuboCop::AST::Node
      # or a Parser::Source::Comment. Both respond to #loc.
      def preceding_comment?(node1, node2)
        node1 && node2 && precede?(node2, node1) &&
          comment_line?(node2.loc.expression.source)
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
        comment.text =~ CommentConfig::COMMENT_DIRECTIVE_REGEXP
      end
    end
  end
end
