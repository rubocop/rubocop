# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking if nodes.
    module IfNode
      def modifier_if?(node)
        node.loc.respond_to?(:keyword) &&
          %w(if unless).include?(node.loc.keyword.source) &&
          node.loc.respond_to?(:end) && node.loc.end.nil?
      end

      def ternary_op?(node)
        node.loc.respond_to?(:question)
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
    end
  end
end
