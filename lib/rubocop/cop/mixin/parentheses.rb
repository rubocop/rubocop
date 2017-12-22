# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling parentheses.
    module Parentheses
      private

      def parens_required?(node)
        range  = node.source_range
        source = range.source_buffer.source
        source[range.begin_pos - 1] =~ /[a-z]/ ||
          source[range.end_pos] =~ /[a-z]/
      end
    end
  end
end
