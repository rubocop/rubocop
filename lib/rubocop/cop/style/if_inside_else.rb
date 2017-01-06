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
        MSG = 'Convert `if` nested inside `else` to `elsif`.'.freeze

        def on_if(node)
          return if node.ternary? || node.unless?

          else_branch = node.else_branch

          return unless else_branch && else_branch.if_type? && else_branch.if?

          add_offense(else_branch, :keyword)
        end
      end
    end
  end
end
