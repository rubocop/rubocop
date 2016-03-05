# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking the closing brace of a literal is
    # either on the same line as the last contained elements, or a new line.
    module MultilineLiteralBraceLayout
      include ConfigurableEnforcedStyle

      def check_brace_layout(node)
        return unless node.loc.begin # Ignore implicit literals.
        return if children(node).empty? # Ignore empty literals.

        if style == :new_line
          return unless closing_brace_on_same_line?(node)

          add_offense(node, :expression, self.class::ALWAYS_NEW_LINE_MESSAGE)
        elsif style == :symmetrical
          if opening_brace_on_same_line?(node)
            return if closing_brace_on_same_line?(node)

            add_offense(node, :expression, self.class::SAME_LINE_MESSAGE)
          else
            return unless closing_brace_on_same_line?(node)

            add_offense(node, :expression, self.class::NEW_LINE_MESSAGE)
          end
        end
      end

      def autocorrect(node)
        if closing_brace_on_same_line?(node)
          lambda do |corrector|
            corrector.insert_before(node.loc.end, "\n".freeze)
          end
        else
          lambda do |corrector|
            corrector.remove(range_with_surrounding_space(node.loc.end,
                                                          :left))
            corrector.insert_after(children(node).last.source_range,
                                   node.loc.end.source)
          end
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
