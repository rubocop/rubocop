# encoding: utf-8
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

          range =
            Parser::Source::Range.new(inner_node.source_range.source_buffer,
                                      inner_node.loc.keyword.begin_pos,
                                      outer_cond.source_range.end_pos)

          lambda do |corrector|
            corrector.replace(range, new_expression(outer_node, inner_node))
          end
        end

        def new_expression(outer_node, inner_node)
          outer_cond, = *outer_node
          inner_cond, = *inner_node

          outer_keyword = outer_node.loc.keyword.source
          inner_keyword = inner_node.loc.keyword.source

          operator = outer_keyword == 'if'.freeze ? '&&'.freeze : '||'.freeze

          outer_expr = outer_cond.source
          outer_expr = "(#{outer_expr})" if outer_cond.or_type? &&
                                            operator == '&&'.freeze
          inner_expr = inner_cond.source

          inner_expr = "(#{inner_expr})" if requires_parens?(inner_cond)
          inner_expr = "!#{inner_expr}" unless outer_keyword == inner_keyword

          "#{outer_node.loc.keyword.source} " \
          "#{outer_expr} #{operator} #{inner_expr}"
        end

        def requires_parens?(node)
          node.or_type? ||
            !(RuboCop::Node::COMPARISON_OPERATORS & node.children).empty?
        end
      end
    end
  end
end
