# encoding: utf-8

module RuboCop
  module Cop
    # This module does auto-correction of nodes that could become grammatically
    # different after the correction. If the code change would alter the
    # abstract syntax tree, it is not done.
    module AutocorrectUnlessChangingAST
      def autocorrect(node)
        current_buffer_src = processed_source.buffer.source
        replaced_range = node.loc.expression
        pre = current_buffer_src[0...replaced_range.begin_pos]
        post = current_buffer_src[replaced_range.end_pos..-1]
        new_buffer_src = pre + rewrite_node(node) + post

        # Make the correction only if it doesn't change the AST for the buffer.
        if processed_source.ast != ProcessedSource.new(new_buffer_src).ast
          return
        end

        correction(node)
      end

      private

      def rewrite_node(node)
        ps = ProcessedSource.new(node.loc.expression.source)
        c = correction(ps.ast)
        Corrector.new(ps.buffer, [c]).rewrite
      end
    end
  end
end
