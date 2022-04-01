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
        include CommentsHelp

        MSG = 'Avoid `%<keyword>s` branches without a body.'

        def on_if(node)
          return if node.body
          return if cop_config['AllowComments'] && contains_comments?(node)

          add_offense(node, message: format(MSG, keyword: node.keyword))
        end
      end
    end
  end
end
