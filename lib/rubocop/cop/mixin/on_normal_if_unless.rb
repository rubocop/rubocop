# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking if and unless expressions.
    module OnNormalIfUnless
      include IfNode

      def on_if(node)
        invoke_hook_for_normal_if_unless(node)
      end

      def invoke_hook_for_normal_if_unless(node)
        # We won't check modifier or ternary conditionals.
        return if modifier_if?(node) || ternary?(node)
        on_normal_if_unless(node)
      end

      def if_else_clause(node)
        return unless node.if_type?

        keyword = node.loc.keyword
        if keyword.is?('if')
          node.children.last
        elsif keyword.is?('elsif')
          node.children.last
        elsif keyword.is?('unless')
          node.children[1]
        end
      end

      def case_else_clause(node)
        node.children.last if node.case_type?
      end
    end
  end
end
