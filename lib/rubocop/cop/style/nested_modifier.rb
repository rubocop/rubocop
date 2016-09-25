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
        include IfNode

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
          return unless modifier?(node)

          ancestor = node.ancestors.first
          return unless ancestor &&
                        [:if, :while, :until].include?(ancestor.type) &&
                        modifier?(ancestor)

          add_offense(node, :keyword)
          ignore_node(node)
        end

        def modifier?(node)
          modifier_if?(node) || modifier_while_or_until?(node)
        end

        def modifier_while_or_until?(node)
          node.loc.respond_to?(:keyword) &&
            %w(while until).include?(node.loc.keyword.source) &&
            node.modifier_form?
        end

        def autocorrect(node)
          return unless node.if_type?

          ancestor = node.ancestors.first
          return unless ancestor.if_type?

          autocorrect_if_unless(ancestor, node)
        end

        def autocorrect_if_unless(outer_node, inner_node)
          outer_cond, = *outer_node

          range = range_between(inner_node.loc.keyword.begin_pos,
                                outer_cond.source_range.end_pos)

          lambda do |corrector|
            corrector.replace(range, new_expression(outer_node, inner_node))
          end
        end

        def new_expression(outer_node, inner_node)
          outer_keyword = outer_node.loc.keyword.source
          operator = replacement_operator(outer_keyword)
          lh_operand = left_hand_operand(outer_node, operator)
          rh_operand = right_hand_operand(inner_node, outer_keyword)

          "#{outer_keyword} #{lh_operand} #{operator} #{rh_operand}"
        end

        def replacement_operator(keyword)
          keyword == 'if'.freeze ? '&&'.freeze : '||'.freeze
        end

        def left_hand_operand(node, operator)
          cond, = *node

          expr = cond.source
          expr = "(#{expr})" if cond.or_type? && operator == '&&'.freeze
          expr
        end

        def right_hand_operand(node, left_hand_keyword)
          cond, = *node
          keyword = node.loc.keyword.source

          expr = cond.source
          expr = "(#{expr})" if requires_parens?(cond)
          expr = "!#{expr}" unless left_hand_keyword == keyword
          expr
        end

        def requires_parens?(node)
          node.or_type? ||
            !(RuboCop::Node::COMPARISON_OPERATORS & node.children).empty?
        end
      end
    end
  end
end
