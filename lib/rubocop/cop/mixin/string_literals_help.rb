# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking single/double quotes.
    module StringLiteralsHelp
      include StringHelp

      private

      def wrong_quotes?(node)
        src = node.source
        return false if src.start_with?('%', '?')

        if style == :single_quotes
          !double_quotes_required?(src)
        else
          !/" | \\[^'] | \#(@|\{)/x.match?(src)
        end
      end
    end
  end
end
