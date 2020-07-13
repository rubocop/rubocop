# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for the presence of `when` branches without a body.
      #
      # @example
      #
      #   # bad
      #   case foo
      #   when bar
      #     do_something
      #   when baz
      #   end
      #
      # @example
      #
      #   # good
      #   case condition
      #   when foo
      #     do_something
      #   when bar
      #     nil
      #   end
      #
      # @example AllowComments: true (default)
      #
      #   # good
      #   case condition
      #   when foo
      #     do_something
      #   when bar
      #     # noop
      #   end
      #
      # @example AllowComments: false
      #
      #   # bad
      #   case condition
      #   when foo
      #     do_something
      #   when bar
      #     # do nothing
      #   end
      #
      class EmptyWhen < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Avoid `when` branches without a body.'

        def on_case(node)
          node.each_when do |when_node|
            next if when_node.body
            next if cop_config['AllowComments'] && comment_lines?(node)

            add_offense(when_node.source_range) do |corrector|
              correct_empty_when(corrector, when_node)
            end
          end
        end

        private

        def correct_empty_when(corrector, when_node)
          return if when_node.parent.else?

          end_pos = correction_end_pos(when_node)
          corrector.remove(
            range_between(when_node.loc.keyword.begin_pos, end_pos)
          )
        end

        def correction_end_pos(when_node)
          sibling = right_sibling_of(when_node)

          if sibling&.when_type?
            next_when.loc.keyword.begin_pos
          else
            # This is the last `when` in the `case`
            when_node.parent.loc.end.begin_pos
          end
        end

        def right_sibling_of(node)
          node.parent.children[node.sibling_index + 1]
        end
      end
    end
  end
end
