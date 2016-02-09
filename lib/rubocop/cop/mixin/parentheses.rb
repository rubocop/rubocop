# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for handling parentheses.
    module Parentheses
      def parens_required?(node)
        range  = node.source_range
        source = range.source_buffer.source
        source[range.begin_pos - 1] =~ /[a-z]/ ||
          source[range.end_pos] =~ /[a-z]/
      end

      def autocorrect(node)
        lambda do |corrector|
          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)
        end
      end
    end
  end
end
