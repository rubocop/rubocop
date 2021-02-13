# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for places where conditional branch makes redundant self-assignment.
      #
      # @example
      #
      #   # bad
      #   foo = condition ? bar : foo
      #
      #   # good
      #   foo = bar if condition
      #
      #   # bad
      #   foo = condition ? foo : bar
      #
      #   # good
      #   foo = bar unless condition
      #
      class RedundantSelfAssignmentBranch < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Remove the self-assignment branch.'

        # @!method bad_method?(node)
        def_node_matcher :bad_method?, <<~PATTERN
          (send nil? :bad_method ...)
        PATTERN

        def on_lvasgn(node)
          variable, expression = *node
          return unless expression&.if_type?
          return unless expression.ternary? || expression.else?

          if_branch = expression.if_branch
          else_branch = expression.else_branch

          if self_assign?(variable, if_branch)
            register_offense(expression, if_branch, else_branch, 'unless')
          elsif self_assign?(variable, else_branch)
            register_offense(expression, else_branch, if_branch, 'if')
          end
        end

        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn

        private

        def self_assign?(variable, branch)
          variable.to_s == branch&.source
        end

        def register_offense(if_node, offense_branch, opposite_branch, keyword)
          add_offense(offense_branch) do |corrector|
            if if_node.ternary?
              replacement = "#{opposite_branch.source} #{keyword} #{if_node.condition.source}"
              corrector.replace(if_node, replacement)
            else
              if_node_loc = if_node.loc

              range = range_by_whole_lines(offense_branch.source_range, include_final_newline: true)
              corrector.remove(range)
              range = range_by_whole_lines(if_node_loc.else, include_final_newline: true)
              corrector.remove(range)

              autocorrect_if_condition(corrector, if_node, if_node_loc, keyword)
            end
          end
        end

        def autocorrect_if_condition(corrector, if_node, if_node_loc, keyword)
          else_branch = if_node.else_branch

          if else_branch.respond_to?(:elsif?) && else_branch.elsif?
            corrector.replace(if_node.condition, else_branch.condition.source)
          else
            corrector.replace(if_node_loc.keyword, keyword)
          end
        end
      end
    end
  end
end
