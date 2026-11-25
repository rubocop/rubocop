# frozen_string_literal: true

module RuboCop
  module Cop
    # Locates the end of a line including any heredoc bodies opened on it.
    module HeredocLines
      def on_new_investigation
        super
        @heredocs_by_line = nil
      end

      private

      def last_line_with_heredocs(node, before: nil)
        heredocs = heredocs_by_line[node.last_line]
        return node.last_line unless heredocs

        heredocs = heredocs.select { |str| str.source_range.begin_pos < before } if before
        heredocs.map { |h| h.loc.heredoc_end.line }.max || node.last_line
      end

      def heredocs_by_line
        @heredocs_by_line ||= processed_source.ast.each_node(:any_str)
                                              .select(&:heredoc?).group_by(&:first_line)
      end
    end
  end
end
