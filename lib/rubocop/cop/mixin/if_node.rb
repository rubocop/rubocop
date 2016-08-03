# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking if nodes.
    module IfNode
      extend NodePattern::Macros

      def ternary?(node)
        node.loc.respond_to?(:question)
      end

      def modifier_if?(node)
        node.loc.respond_to?(:keyword) &&
          %w(if unless).include?(node.loc.keyword.source) && node.modifier_form?
      end

      def elsif?(node)
        node.loc.respond_to?(:keyword) && node.loc.keyword &&
          node.loc.keyword.is?('elsif')
      end

      def if_else?(node)
        node.loc.respond_to?(:else) && node.loc.else
      end

      def if_node_parts(node)
        case node.loc.keyword.source
        when 'if', 'elsif' then condition, body, else_clause = *node
        when 'unless'      then condition, else_clause, body = *node
        else                    condition, body = *node
        end

        [condition, body, else_clause]
      end

      def_node_matcher :guard_clause?, <<-PATTERN
          [{(send nil {:raise :fail} ...) return break next} single_line?]
      PATTERN
    end
  end
end
