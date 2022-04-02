# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the presence of `if`, `elsif` and `unless` branches without a body.
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
            remove_case(corrector, node)
            remove_comments(corrector, node)
          end
        end

        private

        def remove_case(corrector, node)
          end_pos = node.loc.else.nil? ? node.loc.expression.end_pos + 1 : node.loc.else.begin_pos
          corrector.remove(range_between(node.loc.expression.begin_pos, end_pos))
        end

        def remove_comments(corrector, node)
          start_line = node.source_range.line
          end_line = find_end_line(node)

          processed_source.each_comment_in_lines(start_line...end_line).each do |c|
            corrector.remove(range_by_whole_lines(c.loc.expression, include_final_newline: true))
          end
        end
      end
    end
  end
end
