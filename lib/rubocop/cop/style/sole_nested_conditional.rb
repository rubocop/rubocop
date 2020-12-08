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
        include RangeHelp
        extend AutoCorrector

        MSG = 'Consider merging nested conditions into '\
              'outer `%<conditional_type>s` conditions.'

        def on_if(node)
          return if node.ternary? || node.else? || node.elsif?

          if_branch = node.if_branch
          return unless offending_branch?(if_branch)

          message = format(MSG, conditional_type: node.keyword)
          add_offense(if_branch.loc.keyword, message: message) do |corrector|
            autocorrect(corrector, node, if_branch)
          end
        end

        private

        def offending_branch?(branch)
          return false unless branch

          branch.if_type? &&
            !branch.else? &&
            !branch.ternary? &&
            !(branch.modifier_form? && allow_modifier?)
        end

        def autocorrect(corrector, node, if_branch)
          if node.unless?
            corrector.replace(node.loc.keyword, 'if')
            corrector.insert_before(node.condition, '!')
          end

          corrector.wrap(node.condition, '(', ')') if node.condition.or_type?

          and_operator = if_branch.unless? ? ' && !' : ' && '
          if if_branch.modifier_form?
            correct_for_guard_condition_style(corrector, node, if_branch, and_operator)
          else
            correct_for_basic_condition_style(corrector, node, if_branch, and_operator)
            correct_for_comment(corrector, node, if_branch)
          end
        end

        def correct_for_guard_condition_style(corrector, node, if_branch, and_operator)
          condition = if_branch.condition
          corrector.insert_after(node.condition, replacement_condition(and_operator, condition))

          range = range_between(if_branch.loc.keyword.begin_pos, condition.source_range.end_pos)
          corrector.remove(range_with_surrounding_space(range: range, newlines: false))
          corrector.remove(if_branch.loc.keyword)
        end

        def correct_for_basic_condition_style(corrector, node, if_branch, and_operator)
          range = range_between(
            node.condition.source_range.end_pos, if_branch.condition.source_range.begin_pos
          )
          corrector.replace(range, and_operator)
          corrector.remove(range_by_whole_lines(node.loc.end, include_final_newline: true))
          corrector.wrap(if_branch.condition, '(', ')') if wrap_condition?(if_branch.condition)
        end

        def correct_for_comment(corrector, node, if_branch)
          return if config.for_cop('Style/IfUnlessModifier')['Enabled']

          comments = processed_source.comments_before_line(if_branch.source_range.line)
          comment_text = comments.map(&:text).join("\n") << "\n"

          corrector.insert_before(node.loc.keyword, comment_text) unless comments.empty?
        end

        def wrap_condition?(node)
          node.or_type? ||
            (node.send_type? && node.arguments.any? && !node.parenthesized?)
        end

        def replacement_condition(and_operator, condition)
          if wrap_condition?(condition)
            "#{and_operator}(#{condition.source})"
          else
            "#{and_operator}#{condition.source}"
          end
        end

        def allow_modifier?
          cop_config['AllowModifier']
        end
      end
    end
  end
end
