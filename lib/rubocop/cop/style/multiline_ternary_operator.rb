# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for multi-line ternary op expressions.
      #
      # NOTE: `return if ... else ... end` is syntax error. If `return` is used before
      # multiline ternary operator expression, it will be autocorrected to single-line
      # ternary operator. The same is true for `break`, `next`, `yield`, `super`,
      # `defined?` without parentheses, and method call.
      #
      # @example
      #   # bad
      #   a = cond ?
      #     b : c
      #   a = cond ? b :
      #       c
      #   a = cond ?
      #       b :
      #       c
      #
      #   return cond ?
      #          b :
      #          c
      #
      #   # good
      #   a = cond ? b : c
      #   a = if cond
      #     b
      #   else
      #     c
      #   end
      #
      #   return cond ? b : c
      #
      class MultilineTernaryOperator < Base
        include CommentsHelp
        extend AutoCorrector

        MSG_IF = 'Avoid multi-line ternary operators, use `if` or `unless` instead.'
        MSG_SINGLE_LINE = 'Avoid multi-line ternary operators, use single-line instead.'
        SINGLE_LINE_TYPES = %i[return break next send csend super yield].freeze

        def on_if(node)
          return unless offense?(node)

          message = enforce_single_line_ternary_operator?(node) ? MSG_SINGLE_LINE : MSG_IF

          add_offense(node, message: message) do |corrector|
            next if part_of_ignored_node?(node)

            autocorrect(corrector, node)

            ignore_node(node)
          end
        end

        private

        def offense?(node)
          return false unless node.ternary? && node.multiline?
          return false if heredoc_body_outside_branch?(node) || outer_heredoc_body_inside?(node)

          node.source != replacement(node)
        end

        def heredoc_body_outside_branch?(node)
          single_line = enforce_single_line_ternary_operator?(node)

          [node.condition, node.if_branch, node.else_branch].any? do |branch|
            branch.each_node(:any_str).any? do |str|
              next false unless str.heredoc?
              next false if single_line && heredoc_ends_after?(str, node)

              heredoc_ends_after?(str, branch)
            end
          end
        end

        def outer_heredoc_body_inside?(node)
          ternary_range = node.source_range

          processed_source.ast.each_node(:any_str).any? do |str|
            next false if !str.heredoc? || ternary_range.contains?(str.source_range)

            ternary_range.overlaps?(str.loc.heredoc_body)
          end
        end

        def heredoc_ends_after?(heredoc, node)
          heredoc.loc.heredoc_end.end_pos > node.source_range.end_pos
        end

        def autocorrect(corrector, node)
          corrector.replace(node, replacement(node))
          return unless (parent = node.parent)
          return unless (comments_in_condition = comments_in_condition(node))

          corrector.insert_before(parent, comments_in_condition)
        end

        def replacement(node)
          if enforce_single_line_ternary_operator?(node)
            "#{node.condition.source} ? #{node.if_branch.source} : #{node.else_branch.source}"
          else
            <<~RUBY.chop
              if #{node.condition.source}
                #{node.if_branch.source}
              else
                #{node.else_branch.source}
              end
            RUBY
          end
        end

        def comments_in_condition(node)
          comments_in_range(node).map do |comment|
            "#{comment.source}\n"
          end.join
        end

        def enforce_single_line_ternary_operator?(node)
          return false unless (parent = node.parent)
          return !parent.parenthesized? if parent.defined_type?

          SINGLE_LINE_TYPES.include?(parent.type) && !use_assignment_method?(parent)
        end

        def use_assignment_method?(node)
          node.send_type? && node.assignment_method?
        end
      end
    end
  end
end
