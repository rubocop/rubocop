# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to ignore certain methods when
    # parsing using regex patterns.
    module IgnoredMethodPatterns
      private

      def ignored_method_pattern?(name)
        ignored_method_patterns.any? { |pattern| Regexp.new(pattern) =~ name }
      end

      def ignored_method_patterns
        cop_config.fetch('IgnoredMethodPatterns', [])
      end
    end
  end
end
