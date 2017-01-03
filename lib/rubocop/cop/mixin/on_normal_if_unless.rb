# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops checking if and unless expressions.
    module OnNormalIfUnless
      def on_if(node)
        return if node.modifier_form? || node.ternary?

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
