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

        # Make the correction only if it doesn't change the AST. Regenerate the
        # AST for `node` so we get it without context. Otherwise the comparison
        # could be misleading.
        if ast_for(node.loc.expression.source) != ast_for(new_source)
          fail CorrectionNotPossible
        end

        @corrections << c
      end

      private

      def ast_for(source)
        ProcessedSource.new(source).ast
      end

      def rewrite_node(node)
        processed_source = ProcessedSource.new(node.loc.expression.source)
        c = correction(processed_source.ast)
        Corrector.new(processed_source.buffer, [c]).rewrite
      end
    end
  end
end
