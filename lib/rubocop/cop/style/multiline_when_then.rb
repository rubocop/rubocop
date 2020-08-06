# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks uses of the `then` keyword
      # in multi-line when statements.
      #
      # @example
      #   # bad
      #   case foo
      #   when bar then
      #   end
      #
      #   # good
      #   case foo
      #   when bar
      #   end
      #
      #   # good
      #   case foo
      #   when bar then do_something
      #   end
      #
      #   # good
      #   case foo
      #   when bar then do_something(arg1,
      #                              arg2)
      #   end
      #
      class MultilineWhenThen < Base
        include RangeHelp
        extend AutoCorrector

        MSG = 'Do not use `then` for multiline `when` statement.'

        def on_when(node)
          # Without `then`, there's no offense
          return unless node.then?

          # Single line usage of `then` is not an offense
          return if !node.children.last.nil? && !node.multiline?

          # Requires `then` for write `when` and its body on the same line.
          return if require_then?(node)

          # With more than one statements after then, there's not offense
          return if accept_node_type?(node.body)

          range = node.loc.begin
          add_offense(range) do |corrector|
            corrector.remove(
              range_with_surrounding_space(range: range, side: :left, newlines: false)
            )
          end
        end

        private

        def require_then?(when_node)
          return false unless when_node.body

          when_node.loc.line == when_node.body.loc.line
        end

        def accept_node_type?(node)
          node&.begin_type? || node&.array_type? || node&.hash_type?
        end
      end
    end
  end
end
