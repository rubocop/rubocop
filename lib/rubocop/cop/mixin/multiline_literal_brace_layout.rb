# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking the closing brace of a literal is
    # either on the same line as the last contained elements or a new line.
    module MultilineLiteralBraceLayout
      include ConfigurableEnforcedStyle

      private

      def check_brace_layout(node)
        check(node) if brace_layout_checked?(node)
      end

      def brace_layout_checked?(node)
        return false if ignored_literal?(node)

        # If the last node is or contains a conflicting HEREDOC, we don't want
        # to adjust the brace layout because this will result in invalid code.
        !last_line_heredoc?(node.children.last) &&
          !heredoc_opened_on_closing_brace_line?(node) &&
          !heredoc_method_call_to_be_repositioned?(node.children.last)
      end

      # Returns true for the case
      #   [a,
      #    b # comment
      #   ].some_method
      def new_line_needed_before_closing_brace?(node)
        last_element_line = last_element_range_with_trailing_comma(node).last_line

        last_element_commented = processed_source.comment_at_line(last_element_line)

        last_element_commented && (node.chained? || node.argument?)
      end

      def check(node)
        case style
        when :symmetrical then check_symmetrical(node)
        when :new_line then check_new_line(node)
        when :same_line then check_same_line(node)
        end
      end

      def check_new_line(node)
        return unless closing_brace_on_same_line?(node)

        add_offense(node.loc.end, message: self.class::ALWAYS_NEW_LINE_MESSAGE) do |corrector|
          MultilineLiteralBraceCorrector.correct(corrector, node, processed_source)
        end
      end

      def check_same_line(node)
        return if closing_brace_on_same_line?(node)

        add_offense(node.loc.end, message: self.class::ALWAYS_SAME_LINE_MESSAGE) do |corrector|
          next if nested_brace_moved_above_heredoc?(node)

          MultilineLiteralBraceCorrector.correct(corrector, node, processed_source)
        end
      end

      def check_symmetrical(node)
        if opening_brace_on_same_line?(node)
          return if closing_brace_on_same_line?(node)

          add_offense(node.loc.end, message: self.class::SAME_LINE_MESSAGE) do |corrector|
            next if nested_brace_moved_above_heredoc?(node)

            MultilineLiteralBraceCorrector.correct(corrector, node, processed_source)
          end
        else
          return unless closing_brace_on_same_line?(node)

          add_offense(node.loc.end, message: self.class::NEW_LINE_MESSAGE) do |corrector|
            MultilineLiteralBraceCorrector.correct(corrector, node, processed_source)
          end
        end
      end

      def nested_brace_moved_above_heredoc?(node)
        last_line = children(node).last.last_line

        node.each_descendant(node.call_type? ? :call : node.type).any? do |nested|
          next false unless correctable_nested_brace?(nested)

          nested.loc.end.line == last_line &&
            closing_brace_moved_up?(nested) && heredoc_before_closing_brace?(nested)
        end
      end

      def correctable_nested_brace?(node)
        return false if node.args_type? && !node.parent.any_def_type?

        brace_layout_checked?(node) && enabled_lines?(node.loc.end)
      end

      def closing_brace_moved_up?(node)
        return false if closing_brace_on_same_line?(node)

        style == :same_line || (style == :symmetrical && opening_brace_on_same_line?(node))
      end

      def heredoc_before_closing_brace?(node)
        last_element_end = children(node).last.source_range.end_pos

        node.each_descendant(:any_str).any? do |str|
          str.heredoc? &&
            str.loc.heredoc_end.end_pos.between?(last_element_end, node.loc.end.begin_pos)
        end
      end

      def empty_literal?(node)
        children(node).empty?
      end

      def implicit_literal?(node)
        !node.loc.begin
      end

      def ignored_literal?(node)
        implicit_literal?(node) || empty_literal?(node) || node.single_line?
      end

      def children(node)
        node.children
      end

      # This method depends on the fact that we have guarded
      # against implicit and empty literals.
      def opening_brace_on_same_line?(node)
        same_line?(node.loc.begin, children(node).first)
      end

      # This method depends on the fact that we have guarded
      # against implicit and empty literals.
      def closing_brace_on_same_line?(node)
        node.loc.end.line == children(node).last.last_line
      end

      # Starting with the parent node and recursively for the parent node's
      # children, check if the node is a HEREDOC and if the HEREDOC ends below
      # or on the last line of the parent node.
      #
      # Example:
      #
      #   # node is `b: ...` parameter
      #   # last_line_heredoc?(node) => false
      #   foo(a,
      #     b: {
      #       a: 1,
      #       c: <<-EOM
      #         baz
      #       EOM
      #     }
      #   )
      #
      #   # node is `b: ...` parameter
      #   # last_line_heredoc?(node) => true
      #   foo(a,
      #     b: <<-EOM
      #       baz
      #     EOM
      #   )
      def last_line_heredoc?(node, parent = nil)
        parent ||= node

        if node.respond_to?(:loc) &&
           node.loc?(:heredoc_end) &&
           node.loc.heredoc_end.last_line >= parent.last_line
          return true
        end

        return false unless node.respond_to?(:children)

        node.children.any? { |child| last_line_heredoc?(child, parent) }
      end

      def heredoc_opened_on_closing_brace_line?(node)
        closing_brace_line = node.loc.end.line

        node.each_descendant(:any_str).any? do |str|
          str.heredoc? && str.first_line == closing_brace_line
        end
      end

      def heredoc_method_call_to_be_repositioned?(node)
        return false unless config.cop_enabled?('Lint/HeredocMethodCallPosition')

        node.each_node(:call).any? do |call_node|
          receiver = call_node.receiver
          next false unless receiver&.any_str_type? && receiver.heredoc?

          receiver.loc.heredoc_end.end_pos < call_node.source_range.end_pos
        end
      end
    end
  end
end
