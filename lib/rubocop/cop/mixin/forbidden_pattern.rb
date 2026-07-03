# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to forbid certain patterns in a cop.
    module ForbiddenPattern
      def forbidden_pattern?(name)
        forbidden_pattern_regexps.any? { |pattern| pattern.match?(name) }
      end

      def forbidden_patterns
        cop_config.fetch('ForbiddenPatterns', [])
      end

      def forbidden_pattern_regexps
        @forbidden_pattern_regexps ||= forbidden_patterns.map { |pattern| Regexp.new(pattern) }
      end
    end
  end
end
