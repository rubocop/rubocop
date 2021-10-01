# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking single/double quotes.
    module StringLiteralsHelp
      private

      def wrong_quotes?(src_or_node)
        src = src_or_node.is_a?(RuboCop::AST::Node) ? src_or_node.source : src_or_node
        return false if src.start_with?('%', '?')

        if style == :single_quotes
          !double_quotes_required?(src)
        else
          # The string needs single quotes if:
          # 1. It contains a double quote
          # 2. It contains text that would become an escape sequence with double quotes
          # 3. It contains text that would become an interpolation with double quotes
          !/" | (?<!\\)\\[abcefMnrtuUx0-7] | \#[@{$]/x.match?(src)
        end
      end
    end
  end
end
