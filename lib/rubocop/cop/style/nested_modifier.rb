# encoding: utf-8

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

        MSG = 'Avoid using nested modifiers.'

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
            node.loc.respond_to?(:end) && node.loc.end.nil?
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

          operator = outer_keyword == 'if' ? '&&' : '||'

          inner_expr = inner_cond.source
          inner_expr = "(#{inner_expr})" if inner_cond.or_type?
          inner_expr = "!#{inner_expr}" unless outer_keyword == inner_keyword

          "#{outer_node.loc.keyword.source} " \
          "#{outer_cond.source} #{operator} #{inner_expr}"
        end
      end
    end
  end
end
