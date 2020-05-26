# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # If the `else` branch of a conditional consists solely of an `if` node,
      # it can be combined with the `else` to become an `elsif`.
      # This helps to keep the nesting level from getting too deep.
      #
      # @example
      #   # bad
      #   if condition_a
      #     action_a
      #   else
      #     if condition_b
      #       action_b
      #     else
      #       action_c
      #     end
      #   end
      #
      #   # good
      #   if condition_a
      #     action_a
      #   elsif condition_b
      #     action_b
      #   else
      #     action_c
      #   end
      #
      # @example AllowIfModifier: false (default)
      #   # bad
      #   if condition_a
      #     action_a
      #   else
      #     action_b if condition_b
      #   end
      #
      #   # good
      #   if condition_a
      #     action_a
      #   elsif condition_b
      #     action_b
      #   end
      #
      # @example AllowIfModifier: true
      #   # good
      #   if condition_a
      #     action_a
      #   else
      #     action_b if condition_b
      #   end
      #
      #   # good
      #   if condition_a
      #     action_a
      #   elsif condition_b
      #     action_b
      #   end
      #
      class IfInsideElse < Cop
        MSG = 'Convert `if` nested inside `else` to `elsif`.'

        def on_if(node) # rubocop:todo Metrics/CyclomaticComplexity
          return if node.ternary? || node.unless?

          else_branch = node.else_branch

          return unless else_branch&.if_type? && else_branch&.if?
          return if allow_if_modifier_in_else_branch?(else_branch)

          add_offense(else_branch, location: :keyword)
        end

        private

        def allow_if_modifier_in_else_branch?(else_branch)
          allow_if_modifier? && else_branch&.modifier_form?
        end

        def allow_if_modifier?
          cop_config['AllowIfModifier']
        end
      end
    end
  end
end
