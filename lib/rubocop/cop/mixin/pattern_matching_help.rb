# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking whether a node is used in a pattern of
    # pattern matching, where only some expressions are allowed.
    module PatternMatchingHelp
      PATTERN_TYPES = %i[
        array_pattern array_pattern_with_tail begin const_pattern find_pattern hash_pattern
        match_alt match_as pair
      ].freeze

      private

      def in_pattern?(node)
        child = node

        node.each_ancestor do |ancestor|
          case ancestor.type
          when :in_pattern
            return ancestor.pattern.equal?(child)
          when :match_pattern, :match_pattern_p
            return ancestor.children[1].equal?(child)
          when *PATTERN_TYPES
            child = ancestor
          else
            return false
          end
        end

        false
      end
    end
  end
end
