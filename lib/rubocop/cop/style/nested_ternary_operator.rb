# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for nested ternary op expressions.
      #
      # @example
      #   # bad
      #   a ? (b ? b1 : b2) : a2
      #
      #   # good
      #   if a
      #     b ? b1 : b2
      #   else
      #     a2
      #   end
      class NestedTernaryOperator < Base
        extend AutoCorrector
        include RangeHelp
        include IgnoredNode

        MSG = 'Ternary operators must not be nested. Prefer `if` or `else` constructs instead.'

        def on_if(node)
          return unless node.ternary?
          return if part_of_ignored_node?(node)

          if (ternaries = chained_ternaries(node))
            add_offense(node) do |corrector|
              autocorrect_chained(corrector, node, ternaries)
            end
            ignore_node(node)
            return
          end

          node.each_descendant(:if).select(&:ternary?).each do |nested_ternary|
            add_offense(nested_ternary) do |corrector|
              autocorrect_nested(corrector, nested_ternary)
            end
          end
        end

        private

        def if_node(node)
          node = node.parent
          return node if node.if_type?

          if_node(node)
        end

        def autocorrect_else(corrector, if_node, colon_replacement)
          replace_loc_and_whitespace(corrector, if_node.loc.question, "\n")
          replace_loc_and_whitespace(corrector, if_node.loc.colon, colon_replacement)
          corrector.replace(if_node.if_branch, remove_parentheses(if_node.if_branch.source))
        end

        def autocorrect_if(corrector, if_node)
          corrector.wrap(if_node, 'if ', "\nend")
        end

        def remove_parentheses(source)
          return source unless source.start_with?('(')

          source.delete_prefix('(').delete_suffix(')')
        end

        def replace_loc_and_whitespace(corrector, range, replacement)
          corrector.replace(
            range_with_surrounding_space(range: range, whitespace: true),
            replacement
          )
        end

        def autocorrect_nested(corrector, nested_ternary)
          if_node = if_node(nested_ternary)
          return if part_of_ignored_node?(if_node)

          autocorrect_else(corrector, if_node, "\nelse\n")
          autocorrect_if(corrector, if_node)
          ignore_node(if_node)
        end

        def autocorrect_chained(corrector, node, ternaries)
          ternaries.each do |if_node|
            if if_node == ternaries.last
              autocorrect_else(corrector, if_node, "\nelse\n")
            else
              autocorrect_else(corrector, if_node, "\nelsif ")
            end
          end
          autocorrect_if(corrector, node)
        end

        def chained_ternaries(node)
          ternaries = []
          while node.if_type? && node.ternary?
            ternaries << node
            node = node.else_branch
          end
          return if ternaries.count <= 1

          ternaries
        end
      end
    end
  end
end
