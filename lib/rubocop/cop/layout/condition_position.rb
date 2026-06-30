# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks for conditions that are not on the same line as
      # if/while/until.
      #
      # @example
      #
      #   # bad
      #   if
      #     some_condition
      #     do_something
      #   end
      #
      #   # good
      #   if some_condition
      #     do_something
      #   end
      class ConditionPosition < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Place the condition on the same line as `%<keyword>s`.'

        def on_if(node)
          return if node.ternary?

          check(node)
        end

        def on_while(node)
          check(node)
        end
        alias on_until on_while

        private

        def check(node)
          return if node.modifier_form? || node.single_line_condition?

          condition = node.condition
          message = message(condition)

          add_offense(condition, message: message) do |corrector|
            corrector.insert_after(condition.parent.loc.keyword, " #{condition.source}")
            corrector.remove(removal_range(node, condition))
          end
        end

        def message(condition)
          format(MSG, keyword: condition.parent.keyword)
        end

        # When a body statement shares the condition's line (e.g. `while\n cond; body\nend`),
        # removing the whole line would delete the body too. In that case only remove the
        # condition and its trailing separator, preserving the body statement.
        def removal_range(node, condition)
          body = node.body
          if body && body.source_range.line == condition.source_range.last_line
            range_between(condition.source_range.begin_pos, body.source_range.begin_pos)
          else
            range_by_whole_lines(condition.source_range, include_final_newline: true)
          end
        end
      end
    end
  end
end
