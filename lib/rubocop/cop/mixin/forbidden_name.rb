# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to forbid certain identifiers or patterns.
    module ForbiddenName
      SIGILS = '@$' # if a name starts with a sigil it will be removed

      def forbidden_identifiers
        cop_config.fetch('ForbiddenIdentifiers', [])
      end

      def forbidden_patterns
        cop_config.fetch('ForbiddenPatterns', [])
      end

      def matches_forbidden_pattern?(name)
        forbidden_patterns.any? { |pattern| Regexp.new(pattern).match?(name) }
      end

      def forbidden_name?(name)
        name = name.to_s.delete(SIGILS)

        (forbidden_identifiers.any? && forbidden_identifiers.include?(name)) ||
          (forbidden_patterns.any? && matches_forbidden_pattern?(name))
      end
    end
  end
end
