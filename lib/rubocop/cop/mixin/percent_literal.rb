# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling percent literals.
    module PercentLiteral
      private

      def percent_literal?(node)
        return unless (begin_source = begin_source(node))
        begin_source.start_with?('%')
      end

      def process(node, *types)
        return unless percent_literal?(node) && types.include?(type(node))
        on_percent_literal(node)
      end

      def begin_source(node)
        node.loc.begin.source if node.loc.respond_to?(:begin) && node.loc.begin
      end

      def type(node)
        node.loc.begin.source[0..-2]
      end

      # A range containing only the contents of the percent literal (e.g. in
      # %i{1 2 3} this will be the range covering '1 2 3' only)
      def contents_range(node)
        range_between(node.loc.begin.end_pos, node.loc.end.begin_pos)
      end

      # ['a', 'b', 'c'] => %w(a b c)
      def correct_percent(node, char)
        words = node.children
        escape = words.any? { |w| needs_escaping?(w.children[0]) }
        char = char.upcase if escape
        contents = autocorrect_words(words, escape, node.loc.line)

        lambda do |corrector|
          corrector.replace(node.source_range, "%#{char}(#{contents})")
        end
      end

      def autocorrect_words(word_nodes, escape, base_line_number)
        previous_node_line_number = base_line_number
        word_nodes.map do |node|
          number_of_line_breaks = node.loc.line - previous_node_line_number
          line_breaks = "\n" * number_of_line_breaks
          previous_node_line_number = node.loc.line
          content = node.children.first.to_s
          content = escape ? escape_string(content) : content
          content.gsub!(/\)/, '\\)')
          line_breaks + content
        end.join(' ')
      end
    end
  end
end
