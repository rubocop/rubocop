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
      class MultilineWhenThen < Cop
        include RangeHelp

        MSG = 'Do not use `then` for multiline `when` statement.'

        def on_when(node)
          # Without `then`, there's no offense
          return unless node.then?

          # Single line usage of `then` is not an offense
          return if !node.children.last.nil? && !node.multiline? && node.then?

          # With more than one statements after then, there's not offense
          return if node.children.last&.begin_type?

          add_offense(node, location: :begin)
        end

        def autocorrect(node)
          lambda do |corrector|
            corrector.remove(
              range_with_surrounding_space(
                range: node.loc.begin, side: :left
              )
            )
          end
        end
      end
    end
  end
end
