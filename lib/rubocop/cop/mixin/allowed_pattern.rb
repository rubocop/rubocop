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
        patterns = Array(cop_config['AllowedPatterns']).concat(Array(cop_config['IgnoredPatterns']))
        deprecated_values = cop_config_deprecated_methods_values
        return patterns unless deprecated_values.any?(Regexp)

        Array(patterns.concat(deprecated_values))
      end

      def cop_config_deprecated_methods_values
        Array(cop_config['IgnoredMethods']).concat(Array(cop_config['ExcludedMethods']))
      end
    end

    # @deprecated IgnoredPattern class has been replaced with AllowedPattern.
    IgnoredPattern = AllowedPattern
  end
end
