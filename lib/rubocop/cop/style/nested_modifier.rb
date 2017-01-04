# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for nested use of if, unless, while and until in their
      # modifier form.
      #
      # @example
      #
      #   # bad
      #   something if a if b
      #
      #   # good
      #   something if b && a
      class NestedModifier < Cop
        MSG = 'Avoid using nested modifiers.'.freeze

        def on_while(node)
          check(node)
        end

        def on_until(node)
          check(node)
        end

        def on_if(node)
          check(node)
        end

        def check(node)
          return if part_of_ignored_node?(node)
          return unless modifier?(node) && modifier?(node.parent)

          add_offense(node, :keyword)
          ignore_node(node)
        end

        def modifier?(node)
          node && MODIFIER_NODES.include?(node.type) && node.modifier_form?
        end

        def autocorrect(node)
          return unless node.if_type? && node.parent.if_type?

          range = range_between(node.loc.keyword.begin_pos,
                                node.parent.condition.source_range.end_pos)

          lambda do |corrector|
            corrector.replace(range, new_expression(node.parent, node))
          end
        end

        def new_expression(outer_node, inner_node)
          operator = replacement_operator(outer_node.keyword)
          lh_operand = left_hand_operand(outer_node, operator)
          rh_operand = right_hand_operand(inner_node, outer_node.keyword)

          "#{outer_node.keyword} #{lh_operand} #{operator} #{rh_operand}"
        end

        def replacement_operator(keyword)
          keyword == 'if'.freeze ? '&&'.freeze : '||'.freeze
        end

        def left_hand_operand(node, operator)
          expr = node.condition.source
          expr = "(#{expr})" if node.condition.or_type? &&
                                operator == '&&'.freeze
          expr
        end

        def right_hand_operand(node, left_hand_keyword)
          expr = node.condition.source
          expr = "(#{expr})" if requires_parens?(node.condition)
          expr = "!#{expr}" unless left_hand_keyword == node.keyword
          expr
        end

        def requires_parens?(node)
          node.or_type? ||
            !(RuboCop::AST::Node::COMPARISON_OPERATORS & node.children).empty?
        end
      end
    end
  end
end
