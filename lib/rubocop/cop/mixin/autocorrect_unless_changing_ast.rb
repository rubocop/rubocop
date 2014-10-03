# encoding: utf-8

module RuboCop
  module Cop
    # This module does auto-correction of nodes that could become grammatically
    # different after the correction. If the code change would alter the
    # abstract syntax tree, it is not done.
    module AutocorrectUnlessChangingAST
      def autocorrect(node)
        new_source = rewrite_node(node)

        # Make the correction only if it doesn't change the AST. Regenerate the
        # AST for `node` so we get it without context. Otherwise the comparison
        # could be misleading.
        if ast_for(node.loc.expression.source) != ast_for(new_source)
          fail CorrectionNotPossible
        end

        if syntax_error?(node.loc.expression, new_source)
          fail CorrectionNotPossible
        end

        @corrections << correction(node)
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

      # Return true if the change would introduce a syntax error in the buffer
      # source.
      def syntax_error?(replaced_range, new_source)
        current_buffer_src = processed_source.buffer.source
        pre = current_buffer_src[0...replaced_range.begin_pos]
        post = current_buffer_src[replaced_range.end_pos..-1]
        new_buffer_src = pre + new_source + post
        !ProcessedSource.new(new_buffer_src).valid_syntax?
      end
    end
  end
end
