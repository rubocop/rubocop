# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for identical lines at the beginning or end of
      # each branch of a conditional statement.
      #
      # @example
      #   # bad
      #   if condition
      #     do_x
      #     do_z
      #   else
      #     do_y
      #     do_z
      #   end
      #
      #   # good
      #   if condition
      #     do_x
      #   else
      #     do_y
      #   end
      #   do_z
      #
      #   # bad
      #   if condition
      #     do_z
      #     do_x
      #   else
      #     do_z
      #     do_y
      #   end
      #
      #   # good
      #   do_z
      #   if condition
      #     do_x
      #   else
      #     do_y
      #   end
      #
      #   # bad
      #   case foo
      #   when 1
      #     do_x
      #   when 2
      #     do_x
      #   else
      #     do_x
      #   end
      #
      #   # good
      #   case foo
      #   when 1
      #     do_x
      #     do_y
      #   when 2
      #     # nothing
      #   else
      #     do_x
      #     do_z
      #   end
      class IdenticalConditionalBranches < Cop
        MSG = 'Move `%<source>s` out of the conditional.'.freeze

        def on_if(node)
          return if node.elsif?

          branches = expand_elses(node.else_branch).unshift(node.if_branch)

          # return if any branch is empty. An empty branch can be an `if`
          # without an `else` or a branch that contains only comments.
          return if branches.any?(&:nil?)

          check_branches(branches)
        end

        def on_case(node)
          return unless node.else? && node.else_branch

          branches = node.when_branches.map(&:body).push(node.else_branch)

          return if branches.any?(&:nil?)

          check_branches(branches)
        end

        private

        def check_branches(branches)
          tails = branches.compact.map { |branch| tail(branch) }
          check_expressions(tails)
          heads = branches.compact.map { |branch| head(branch) }
          check_expressions(heads)
        end

        def check_expressions(expressions)
          return unless expressions.size > 1 && expressions.uniq.one?

          expressions.each do |expression|
            add_offense(expression)
          end
        end

        def message(node)
          format(MSG, source: node.source)
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

        def tail(node)
          node.begin_type? ? node.children.last : node
        end

        def head(node)
          node.begin_type? ? node.children.first : node
        end
      end
    end
  end
end
