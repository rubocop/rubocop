# frozen_string_literal: true

module RuboCop
  # @api private
  module OptimizedPatterns
    # A wrapper around patterns array to perform optimized search.
    # @api private
    class PatternsSet
      def initialize(patterns)
        @strings = Set.new
        @patterns = []
        partition_patterns(patterns)
      end

      def match?(path)
        @strings.include?(path) || @patterns.any? { |pattern| PathUtil.match_path?(pattern, path) }
      end

      private

      def partition_patterns(patterns)
        patterns.each do |pattern|
          if pattern.is_a?(String) && !pattern.match?(/[*{\[?]/)
            @strings << pattern
          else
            @patterns << pattern
          end
        end
      end
    end

    @cache = {}.compare_by_identity

    def self.from(patterns)
      @cache[patterns] ||= PatternsSet.new(patterns)
    end
  end
end
