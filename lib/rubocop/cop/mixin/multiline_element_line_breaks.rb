# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking for a line break before each
    # element in a multi-line collection.
    module MultilineElementLineBreaks
      private

      def check_line_breaks(_node, children, ignore_last: false)
        return if all_on_same_line?(children, ignore_last: ignore_last)

        last_seen_line = -1
        children.each_with_index do |child, index|
          if last_seen_line >= child.first_line
            next if heredoc_opened_before?(children.first(index), child)

            add_offense(child) { |corrector| EmptyLineCorrector.insert_before(corrector, child) }
          else
            last_seen_line = child.last_line
          end
        end
      end

      def all_on_same_line?(nodes, ignore_last: false)
        return true if nodes.empty?

        return same_line?(nodes.first, nodes.last) if ignore_last

        nodes.first.first_line == nodes.last.last_line
      end

      def heredoc_opened_before?(previous_children, child)
        previous_children.any? do |previous|
          previous.each_node(:any_str).any? do |str|
            str.heredoc? && same_line?(str, child)
          end
        end
      end
    end
  end
end
