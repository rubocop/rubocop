# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # If the `else` branch of a conditional consists solely of an `if` node,
      # it can be combined with the `else` to become an `elsif`.
      # This helps to keep the nesting level from getting too deep.
      #
      # @example
      #   @good
      #   if condition_a
      #     action_a
      #   elsif condition_b
      #     action_b
      #   else
      #     action_c
      #   end
      #
      #   @bad
      #   if condition_a
      #     action_a
      #   else
      #     if condition_b
      #       action_b
      #     else
      #       action_c
      #     end
      #   end
      class IfInsideElse < Cop
        include IfNode

        MSG = 'Convert `if` nested inside `else` to `elsif`.'.freeze

        def on_if(node)
          _cond, _if_branch, else_branch = *node
          return unless else_branch
          return unless else_branch.if_type?
          return if ternary?(node) || ternary?(else_branch)
          return unless else_branch.loc.keyword.is?('if')
          return if node.loc.keyword.is?('unless')

          add_offense(else_branch, :keyword, MSG)
        end
      end
    end
  end
end
