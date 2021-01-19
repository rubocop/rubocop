# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for redundant `if` with boolean literal branches.
      # It checks only conditions to return boolean value (`true` or `false`) for safe detection.
      # The conditions to be checked are comparison methods, predicate methods, and double negative.
      #
      # @example
      #   # bad
      #   if foo == bar
      #     true
      #   else
      #     false
      #   end
      #
      #   # bad
      #   foo == bar ? true : false
      #
      #   # good
      #   foo == bar
      #
      class IfWithBooleanLiteralBranches < Base
        extend AutoCorrector

        MSG = 'Remove redundant %<keyword>s with boolean literal branches.'

        def_node_matcher :if_with_boolean_literal_branches?, <<~PATTERN
          (if #return_boolean_value? {(true) (false) | (false) (true)})
        PATTERN
        def_node_matcher :double_negative?, '(send (send _ :!) :!)'

        def on_if(node)
          return unless if_with_boolean_literal_branches?(node)

          condition = node.condition
          range, keyword = if node.ternary?
                             range = condition.source_range.end.join(node.source_range.end)

                             [range, 'ternary operator']
                           else
                             keyword = node.loc.keyword

                             [keyword, "`#{keyword.source}`"]
                           end

          add_offense(range, message: format(MSG, keyword: keyword)) do |corrector|
            replacement = replacement_condition(node, condition)

            corrector.replace(node, replacement)
          end
        end

        private

        def return_boolean_value?(condition)
          if condition.begin_type?
            return_boolean_value?(condition.children.first)
          elsif condition.or_type?
            return_boolean_value?(condition.lhs) && return_boolean_value?(condition.rhs)
          elsif condition.and_type?
            return_boolean_value?(condition.rhs)
          else
            assume_boolean_value?(condition)
          end
        end

        def assume_boolean_value?(condition)
          return false unless condition.send_type?

          condition.comparison_method? || condition.predicate_method? || double_negative?(condition)
        end

        def replacement_condition(node, condition)
          bang = '!' if opposite_condition?(node)

          if bang && require_parentheses?(condition)
            "#{bang}(#{condition.source})"
          else
            "#{bang}#{condition.source}"
          end
        end

        def opposite_condition?(node)
          !node.unless? && node.if_branch.false_type? || node.unless? && node.if_branch.true_type?
        end

        def require_parentheses?(condition)
          condition.and_type? || condition.or_type? ||
            condition.send_type? && condition.comparison_method?
        end
      end
    end
  end
end
