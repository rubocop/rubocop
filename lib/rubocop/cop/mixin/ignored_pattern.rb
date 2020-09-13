# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to ignore certain lines when
    # parsing.
    module IgnoredPattern
      private

      def ignored_line?(line)
        line = if line.respond_to?(:source_line)
                 line.source_line
               elsif line.respond_to?(:node)
                 line.node.source_range.source_line
               end

        matches_ignored_pattern?(line)
      end

      def matches_ignored_pattern?(line)
        ignored_patterns.any? { |pattern| Regexp.new(pattern).match?(line) }
      end

      def ignored_patterns
        cop_config['IgnoredPatterns'] || []
      end
    end
  end
end
