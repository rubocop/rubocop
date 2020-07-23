# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # If the branch of a conditional consists solely of a conditional node,
      # its conditions can be combined with the conditions of the outer branch.
      # This helps to keep the nesting level from getting too deep.
      #
      # @example
      #   # bad
      #   if condition_a
      #     if condition_b
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   if condition_a && condition_b
      #     do_something
      #   end
      #
      # @example AllowModifier: false (default)
      #   # bad
      #   if condition_a
      #     do_something if condition_b
      #   end
      #
      # @example AllowModifier: true
      #   # good
      #   if condition_a
      #     do_something if condition_b
      #   end
      #
      class SoleNestedConditional < Base
        MSG = 'Consider merging nested conditions into '\
              'outer `%<conditional_type>s` conditions.'

        def on_if(node)
          return if node.ternary? || node.else? || node.elsif?

          branch = node.if_branch
          return unless offending_branch?(branch)

          message = format(MSG, conditional_type: node.keyword)
          add_offense(branch.loc.keyword, message: message)
        end

        private

        def offending_branch?(branch)
          return false unless branch

          branch.if_type? &&
            !branch.else? &&
            !branch.ternary? &&
            !(branch.modifier_form? && allow_modifier?)
        end

        def allow_modifier?
          cop_config['AllowModifier']
        end
      end
    end
  end
end
