# encoding: utf-8

module RuboCop
  module Cop
    # Common functionality for cops checking single/double quotes.
    module StringLiteralsHelp
      include StringHelp

      def wrong_quotes?(node, style)
        src = node.source
        return false if src.start_with?('%', '?')
        if style == :single_quotes
          src !~ /'/ && !double_quotes_acceptable?(node.str_content)
        else
          src !~ /" | \\ | \#/x
        end
      end

      def autocorrect(node)
        lambda do |corrector|
          str = node.str_content
          if style == :single_quotes
            corrector.replace(node.loc.expression, to_string_literal(str))
          else
            corrector.replace(node.loc.expression, str.inspect)
          end
        end
      end
    end
  end
end
