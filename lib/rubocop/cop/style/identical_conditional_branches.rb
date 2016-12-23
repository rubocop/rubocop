# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for identical lines at the beginning or end of
      # each branch of a conditional statement.
      #
      # @example
      #   @bad
      #   if condition
      #     do_x
      #     do_z
      #   else
      #     do_y
      #     do_z
      #   end
      #
      #   @good
      #   if condition
      #     do_x
      #   else
      #     do_y
      #   end
      #   do_z
      #
      #   @bad
      #   if condition
      #     do_z
      #     do_x
      #   else
      #     do_z
      #     do_y
      #   end
      #
      #   @good
      #   do_z
      #   if condition
      #     do_x
      #   else
      #     do_y
      #   end
      class IdenticalConditionalBranches < Cop
        include IfNode

        MSG = 'Move `%s` out of the conditional.'.freeze

        def on_if(node)
          return if elsif?(node)
          _condition, if_branch, else_branch = *node
          branches = expand_elses(else_branch).unshift(if_branch)

          # return if any branch is empty. An empty branch can be an `if`
          # without an `else`, or a branch that contains only comments.
          return if branches.any?(&:nil?)

          check_branches(branches)
        end

        def on_case(node)
          return unless node.loc.else
          _condition, *when_branches, else_branch = *node
          return unless else_branch # empty else
          when_branches = expand_when_branches(when_branches)

          check_branches(when_branches.push(else_branch))
        end

        private

        def check_branches(branches)
          tails = branches.map { |branch| tail(branch) }
          check_expressions(tails)
          heads = branches.map { |branch| head(branch) }
          check_expressions(heads)
        end

        def check_expressions(expressions)
          return unless expressions.all? { |expr| expr == expressions[0] }
          expressions.each do |expression|
            add_offense(expression, :expression, format(MSG, expression.source))
          end
        end

        # `elsif` branches show up in the if node as nested `else` branches. We
        # need to recursively iterate over all `else` branches.
        def expand_elses(branch)
          if branch.nil?
            [nil]
          elsif branch.if_type?
            _condition, elsif_branch, else_branch = *branch
            expand_elses(else_branch).unshift(elsif_branch)
          else
            [branch]
          end
        end

        # `when` nodes contain the entire branch including the condition.
        # We only need the contents of the branch, not the condition.
        def expand_when_branches(when_branches)
          when_branches.map { |branch| branch.children[1] }
        end

        def tail(node)
          if node && node.begin_type?
            node.children.last
          else
            node
          end
        end

        def head(node)
          if node && node.begin_type?
            node.children.first
          else
            node
          end
        end
      end
    end
  end
end
