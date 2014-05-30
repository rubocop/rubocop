# encoding: utf-8

module RuboCop
  module Cop
    # This module does auto-correction of nodes that could become grammatically
    # different after the correction. If the code change would alter the
    # abstract syntax tree, it is not done.
    module AutocorrectUnlessChangingAST
      def autocorrect(node)
        c = correction(node)
        new_source = rewrite_node(node)

        # Make the correction only if it doesn't change the AST.
        fail CorrectionNotPossible if node != SourceParser.parse(new_source).ast

        @corrections << c
      end

      def rewrite_node(node)
        processed_source = SourceParser.parse(node.loc.expression.source)
        c = correction(processed_source.ast)
        Corrector.new(processed_source.buffer, [c]).rewrite
      end
    end
  end
end
