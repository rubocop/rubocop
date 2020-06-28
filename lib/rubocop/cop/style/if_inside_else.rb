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
      class IfInsideElse < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Convert `if` nested inside `else` to `elsif`.'

        def on_if(node)
          return if node.ternary? || node.unless?

          else_branch = node.else_branch

          return unless else_branch&.if_type? && else_branch&.if?
          return if allow_if_modifier_in_else_branch?(else_branch)

          add_offense(else_branch.loc.keyword) do |corrector|
            autocorrect(corrector, else_branch)
          end
        end

        private

        def autocorrect(corrector, node)
          if node.modifier_form?
            correct_to_elsif_from_modifier_form(corrector, node)
            end_range = node.parent.loc.end
          else
            correct_to_elsif_from_if_inside_else_form(corrector, node, node.condition)
            end_range = node.loc.end
          end
          corrector.remove(range_by_whole_lines(end_range, include_final_newline: true))
          corrector.remove(
            range_by_whole_lines(node.if_branch.source_range, include_final_newline: true)
          )
        end

        def correct_to_elsif_from_modifier_form(corrector, node)
          corrector.replace(node.parent.loc.else, <<~RUBY.chop)
            elsif #{node.condition.source}
            #{indent(node.if_branch)}#{node.if_branch.source}
            end
          RUBY
        end

        def correct_to_elsif_from_if_inside_else_form(corrector, node, condition)
          corrector.replace(node.parent.loc.else, "elsif #{condition.source}")
          if_condition_range = range_between(
            node.loc.keyword.begin_pos, condition.source_range.end_pos
          )
          corrector.replace(if_condition_range, node.if_branch.source)
          corrector.remove(condition)
        end

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
