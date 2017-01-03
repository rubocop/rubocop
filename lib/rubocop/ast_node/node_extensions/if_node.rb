# frozen_string_literal: true

module RuboCop
  module NodeExtension
    # A node extension for `if` nodes.
    module IfNode
      def if?
        keyword == 'if'
      end

      def unless?
        keyword == 'unless'
      end

      def elsif?
        keyword == 'elsif'
      end

      def keyword
        ternary? ? '' : loc.keyword.source
      end

      def ternary?
        loc.respond_to?(:question)
      end

      def else?
        loc.respond_to?(:else) && loc.else
      end

      def modifier_form?
        (if? || unless?) && super
      end

      def condition
        if_node_parts[0]
      end

      def if_branch
        if_node_parts[1]
      end

      def nested_conditional?
        node_parts[1..2].compact.any?(&:if_type?)
      end

      def false_branch
        node_parts[2]
      end
      alias else_branch false_branch

      def if_node_parts
        if unless?
          condition, else_clause, if_clause = *self
        else
          condition, if_clause, else_clause = *self
        end

        [condition, if_clause, else_clause]
      end
    end
  end
end
