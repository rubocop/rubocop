# encoding: utf-8

module Rubocop
  module Cop
    # This module does auto-correction of nodes that could become grammatically
    # different after the correction. If the code change would alter the
    # abstract syntax tree, it is not done.
    module AutocorrectUnlessChangingAST
      def autocorrect(node)
        c = correction(node)
        new_source = rewrite_node(node, c)

        # Make the correction only if it doesn't change the AST.
        if node != SourceParser.parse(new_source).ast
          fail CorrectionNotPossible
        end

        @corrections << c
      end

      def rewrite_node(node, correction)
        processed_source = SourceParser.parse(node.loc.expression.source)
        c = correction(processed_source.ast)
        Corrector.new(processed_source.buffer, [c]).rewrite
      end
    end
  end
end
