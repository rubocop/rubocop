# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for handling parentheses.
    module Parentheses
      def parens_required?(node)
        source_buffer = node.loc.expression.source_buffer
        source_buffer.source[node.loc.expression.begin_pos - 1] =~ /[a-z]/ ||
          source_buffer.source[node.loc.expression.end_pos] =~ /[a-z]/
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
