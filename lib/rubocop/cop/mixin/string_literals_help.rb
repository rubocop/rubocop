# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking single/double quotes.
    module StringLiteralsHelp
      include StringHelp

      def wrong_quotes?(node)
        src = node.source
        return false if src.start_with?('%', '?')
        if style == :single_quotes
          !double_quotes_required?(src)
        else
          src !~ /" | \\[^'] | \#(@|\{)/x
        end
      end

      def autocorrect(node)
        return if node.dstr_type?

        lambda do |corrector|
          str = node.str_content
          if style == :single_quotes
            corrector.replace(node.source_range, to_string_literal(str))
          else
            corrector.replace(node.source_range, str.inspect)
          end
        end
      end
    end
  end
end
