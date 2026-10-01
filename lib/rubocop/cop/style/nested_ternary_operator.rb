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

        MSG = 'Ternary operators must not be nested. Prefer `if` or `else` constructs instead.'

        def on_if(node)
          return unless node.ternary?

          node.each_descendant(:if).select(&:ternary?).each do |nested_ternary|
            add_offense(nested_ternary) do |corrector|
              next if part_of_ignored_node?(node)

              autocorrect(corrector, node)
              ignore_node(node)
            end
          end
        end

        private

        def autocorrect(corrector, if_node)
          replace_loc_and_whitespace(corrector, if_node.loc.question, "\n")
          replace_loc_and_whitespace(corrector, if_node.loc.colon, "\nelse\n")
          remove_parentheses(corrector, if_node.if_branch)

          if modifier_position?(if_node)
            corrector.wrap(if_node, '(if ', "\nend)")
          else
            corrector.wrap(if_node, 'if ', "\nend")
          end
        end

        def remove_parentheses(corrector, node)
          return unless node.begin_type? && node.parenthesized_call?

          corrector.remove(node.loc.begin)
          corrector.remove(node.loc.end)
        end

        # An `if` right after `return`, as the operand of `not` or `defined?`, or as
        # the first argument of a call without parentheses would be parsed as a modifier.
        def modifier_position?(node)
          return false unless (parent = node.parent)
          return true if parent.type?(:return, :break, :next)
          return false if !parent.type?(:call, :super, :yield, :defined?) || parent.parenthesized?

          parent.prefix_not? || parent.first_argument.equal?(node)
        end

        def replace_loc_and_whitespace(corrector, range, replacement)
          corrector.replace(
            range_with_surrounding_space(range: range, whitespace: true),
            replacement
          )
        end
      end
    end
  end
end
