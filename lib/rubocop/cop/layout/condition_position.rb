# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # This cop checks for conditions that are not on the same line as
      # if/while/until.
      #
      # @example
      #
      #   # bad
      #
      #   if
      #     some_condition
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   if some_condition
      #     do_something
      #   end
      class ConditionPosition < Cop
        include RangeHelp

        MSG = 'Place the condition on the same line as `%<keyword>s`.'

        def on_if(node)
          return if node.ternary?

          check(node)
        end

        def on_while(node)
          check(node)
        end
        alias on_until on_while

        def autocorrect(node)
          lambda do |corrector|
            range = range_by_whole_lines(
              node.source_range, include_final_newline: true
            )

            corrector.insert_after(node.parent.loc.keyword, " #{node.source}")
            corrector.remove(range)
          end
        end

        private

        def check(node)
          return if node.modifier_form? || node.single_line_condition?

          add_offense(node.condition)
        end

        def message(node)
          format(MSG, keyword: node.parent.keyword)
        end
      end
    end
  end
end
