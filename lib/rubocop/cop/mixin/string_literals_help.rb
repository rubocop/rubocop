# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for cops checking single/double quotes.
    module StringLiteralsHelp
      include StringHelp

      def wrong_quotes?(node, style)
        src = node.loc.expression.source
        return false if src.start_with?('%') || src.start_with?('?')
        if style == :single_quotes
          src !~ /'/ && src !~ StringHelp::ESCAPED_CHAR_REGEXP
        else
          src !~ /" | \\/x
        end
      end

      def autocorrect(node)
        lambda do |corrector|
          replacement = node.loc.begin.is?('"') ? "'" : '"'
          corrector.replace(node.loc.begin, replacement)
          corrector.replace(node.loc.end, replacement)
        end
      end
    end
  end
end
