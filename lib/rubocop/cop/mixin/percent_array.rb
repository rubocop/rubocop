# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling percent arrays.
    module PercentArray
      private

      # Ruby does not allow percent arrays in an ambiguous block context.
      #
      # @example
      #
      #   foo %i[bar baz] { qux }
      def invalid_percent_array_context?(node)
        parent = node.parent

        parent&.send_type? && parent.arguments.include?(node) &&
          !parent.parenthesized? && parent&.block_literal?
      end

      def allowed_bracket_array?(node)
        comments_in_array?(node) || below_array_length?(node) ||
          invalid_percent_array_context?(node)
      end

      def message(_node)
        style == :percent ? self.class::PERCENT_MSG : self.class::ARRAY_MSG
      end

      def comments_in_array?(node)
        line_span = node.source_range.first_line...node.source_range.last_line
        processed_source.each_comment_in_lines(line_span).any?
      end

      def check_percent_array(node)
        array_style_detected(:percent, node.values.size)

        return unless style == :brackets

        add_offense(node) { |corrector| correct_bracketed(corrector, node) }
      end

      def check_bracketed_array(node, literal_prefix)
        return if allowed_bracket_array?(node)

        array_style_detected(:brackets, node.values.size)

        return unless style == :percent

        add_offense(node) do |corrector|
          percent_literal_corrector = PercentLiteralCorrector.new(@config, @preferred_delimiters)
          percent_literal_corrector.correct(corrector, node, literal_prefix)
        end
      end
    end
  end
end
