# encoding: utf-8

module RuboCop
  module Cop
    # This module does auto-correction of nodes that could become grammatically
    # different after the correction. If the code change would alter the
    # abstract syntax tree, it is not done.
    #
    # However, if the code change merely introduces extraneous "begin" nodes
    # which do not change the meaning of the code, it is still accepted.
    #
    module AutocorrectUnlessChangingAST
      def autocorrect(node)
        current_buffer_src = processed_source.buffer.source
        replaced_range = node.loc.expression
        pre = current_buffer_src[0...replaced_range.begin_pos]
        post = current_buffer_src[replaced_range.end_pos..-1]
        new_buffer_src = pre + rewrite_node(node) + post
        new_processed_src = ProcessedSource.new(new_buffer_src)

        # Make the correction only if it doesn't change the AST for the buffer.
        return if !new_processed_src.ast ||
                  (INLINE_BEGIN.process(processed_source.ast) !=
                   INLINE_BEGIN.process(new_processed_src.ast))

        correction(node)
      end

      private

      def rewrite_node(node)
        ps = ProcessedSource.new(node.source)
        c = correction(ps.ast)
        Corrector.new(ps.buffer, [c]).rewrite
      end

      # 'begin' nodes with a single child can be removed without changing
      # the semantics of an AST. Canonicalizing an AST in this way can help
      # us determine whether it has really changed in a meaningful way, or
      # not. This means we can auto-correct in cases where we would otherwise
      # refrain from doing so.
      #
      # If any other simplifications can be done to an AST without changing
      # its meaning, they should be added here (and the class renamed).
      # This will make autocorrection more powerful across the board.
      #
      class InlineBeginNodes < Parser::AST::Processor
        def on_begin(node)
          node.children.one? ? process(node.children[0]) : super
        end
      end

      INLINE_BEGIN = InlineBeginNodes.new
    end
  end
end
