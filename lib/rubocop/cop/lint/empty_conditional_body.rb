# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the presence of `if`, `elsif` and `unless` branches without a body.
      #
      # NOTE: empty `else` branches are handled by `Style/EmptyElse`.
      #
      # @safety
      #   Autocorrection for this cop is not safe. The conditions for empty branches that
      #   the autocorrection removes may have side effects, or the logic in subsequent
      #   branches may change due to the removal of a previous condition.
      #
      # @example
      #   # bad
      #   if condition
      #   end
      #
      #   # bad
      #   unless condition
      #   end
      #
      #   # bad
      #   if condition
      #     do_something
      #   elsif other_condition
      #   end
      #
      #   # good
      #   if condition
      #     do_something
      #   end
      #
      #   # good
      #   unless condition
      #     do_something
      #   end
      #
      #   # good
      #   if condition
      #     do_something
      #   elsif other_condition
      #     do_something_else
      #   end
      #
      # @example AllowComments: true (default)
      #   # good
      #   if condition
      #     do_something
      #   elsif other_condition
      #     # noop
      #   end
      #
      # @example AllowComments: false
      #   # bad
      #   if condition
      #     do_something
      #   elsif other_condition
      #     # noop
      #   end
      #
      class EmptyConditionalBody < Base
        extend AutoCorrector
        include CommentsHelp
        include RangeHelp

        MSG = 'Avoid `%<keyword>s` branches without a body.'

        def on_if(node)
          return if node.body
          return if cop_config['AllowComments'] && contains_comments?(node)

          add_offense(node, message: format(MSG, keyword: node.keyword)) do |corrector|
            autocorrect(corrector, node)
          end
        end

        private

        def autocorrect(corrector, node)
          remove_comments(corrector, node)
          remove_empty_branch(corrector, node)
          correct_other_branches(corrector, node)
        end

        def remove_comments(corrector, node)
          comments_in_range(node).each do |comment|
            range = range_by_whole_lines(comment.loc.expression, include_final_newline: true)
            corrector.remove(range)
          end
        end

        def remove_empty_branch(corrector, node)
          corrector.remove(deletion_range(branch_range(node)))
        end

        def correct_other_branches(corrector, node)
          return unless (node.if? || node.unless?) && node.else_branch

          if node.else_branch.if_type?
            # Replace an orphaned `elsif` with `if`
            corrector.replace(node.else_branch.loc.keyword, 'if')
          else
            # Flip orphaned `else`
            corrector.replace(node.loc.else, "#{node.inverse_keyword} #{node.condition.source}")
          end
        end

        def branch_range(node)
          if node.loc.else
            node.source_range.with(end_pos: node.loc.else.begin_pos - 1)
          else
            node.source_range
          end
        end

        def deletion_range(range)
          # Collect a range between the start of the `if` node and the next relevant node,
          # including final new line.
          # Based on `RangeHelp#range_by_whole_lines` but allows the `if` to not start
          # on the first column.
          buffer = @processed_source.buffer

          last_line = buffer.source_line(range.last_line)
          end_offset = last_line.length - range.last_column + 1

          range.adjust(end_pos: end_offset).intersect(buffer.source_range)
        end
      end
    end
  end
end
