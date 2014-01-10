# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for cops checking if and unless statements.
    module IfThenElse
      def on_if(node)
        check(node)
      end

      def on_unless(node)
        check(node)
      end

      def check(node)
        # We won't check modifier or ternary conditionals.
        return unless node.loc.expression.source =~ /\A(if|unless)\b/
        return unless offending_line(node)
        add_offence(node, :expression, error_message(node))
      end
    end
  end
end
