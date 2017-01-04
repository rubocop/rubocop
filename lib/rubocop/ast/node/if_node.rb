# frozen_string_literal: true

module RuboCop
  module AST
    # A node extension for `if` nodes.
    class IfNode < Node
      include ConditionalNode
      include ModifierNode

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

      def inverse_keyword
        if keyword == 'if'
          'unless'
        elsif keyword == 'unless'
          'if'
        else
          ''
        end
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

      def true_branch
        node_parts[1]
      end

      def nested_conditional?
        node_parts[1..2].compact.any?(&:if_type?)
      end

      def false_branch
        node_parts[2]
      end
      alias else_branch false_branch

      def node_parts
        if unless?
          condition, false_branch, true_branch = *self
        else
          condition, true_branch, false_branch = *self
        end

        [condition, true_branch, false_branch]
      end
    end
  end
end
