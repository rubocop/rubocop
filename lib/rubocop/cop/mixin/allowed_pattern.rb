# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to ignore certain lines when
    # parsing.
    module AllowedPattern
      private

      def allowed_line?(line)
        line = if line.respond_to?(:source_line)
                 line.source_line
               elsif line.respond_to?(:node)
                 line.node.source_range.source_line
               end

        matches_allowed_pattern?(line)
      end

      # @deprecated Use allowed_line? instead
      alias ignored_line? allowed_line?

      def matches_allowed_pattern?(line)
        allowed_patterns.any? { |pattern| Regexp.new(pattern).match?(line) }
      end

      # @deprecated Use matches_allowed_pattern?? instead
      alias matches_ignored_pattern? matches_allowed_pattern?

      def allowed_patterns
        # Since there could be a pattern specified in the default config, merge the two
        # arrays together.
        if cop_config_deprecated_methods_values.any?(Regexp)
          cop_config_patterns_values + cop_config_deprecated_methods_values
        else
          cop_config_patterns_values
        end
      end

      def cop_config_patterns_values
        @cop_config_patterns_values ||=
          Array(cop_config.fetch('AllowedPatterns', [])) +
          Array(cop_config.fetch('IgnoredPatterns', []))
      end

      def cop_config_deprecated_methods_values
        @cop_config_deprecated_methods_values ||=
          Array(cop_config.fetch('IgnoredMethods', [])) +
          Array(cop_config.fetch('ExcludedMethods', []))
      end
    end

    # @deprecated IgnoredPattern class has been replaced with AllowedPattern.
    IgnoredPattern = AllowedPattern
  end
end
