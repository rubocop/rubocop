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
        MSG = 'Avoid `when` branches without a body.'

        def on_case(node)
          node.each_when do |when_node|
            next if when_node.body
            next if cop_config['AllowComments'] && comment_lines?(node)

            add_offense(when_node)
          end
        end
      end
    end
  end
end
