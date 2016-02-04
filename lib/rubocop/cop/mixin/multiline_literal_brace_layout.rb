# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking that the closing brace of a literal is
    # symmetrical with respect to the opening brace and contained elements.
    module MultilineLiteralBraceLayout
      def check_brace_layout(node)
        return unless node.loc.begin # Ignore implicit literals.
        return if children(node).empty? # Ignore empty literals.

        if opening_brace_on_same_line?(node)
          return if closing_brace_on_same_line?(node)

          add_offense(node, :expression, self.class::SAME_LINE_MESSAGE)
        else
          return unless closing_brace_on_same_line?(node)

          add_offense(node, :expression, self.class::NEW_LINE_MESSAGE)
        end
      end

      def autocorrect(node)
        if closing_brace_on_same_line?(node)
          lambda do |corrector|
            corrector.insert_before(node.loc.end, "\n".freeze)
          end
        else
          range = Parser::Source::Range.new(
            node.source_range.source_buffer,
            children(node).last.source_range.end_pos,
            node.loc.end.begin_pos)

          ->(corrector) { corrector.remove(range) }
        end
      end

      private

      def children(node)
        node.children
      end

      # This method depends on the fact that we have guarded
      # against implicit and empty literals.
      def opening_brace_on_same_line?(node)
        node.loc.begin.line == children(node).first.loc.first_line
      end

      # This method depends on the fact that we have guarded
      # against implicit and empty literals.
      def closing_brace_on_same_line?(node)
        node.loc.end.line == children(node).last.loc.last_line
      end
    end
  end
end
