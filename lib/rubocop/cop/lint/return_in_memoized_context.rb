# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the use of a return in a memoized context. This prevents the
      # value from being memoized.
      #
      # @example
      #
      #   # bad
      #   def foo
      #     @foo ||= begin
      #       return :bar if baz?
      #       qux
      #     end
      #   end
      #
      # @example
      #
      #   # good
      #   def foo
      #     return @foo if defined?(@foo)
      #     return @foo = :bar if baz?
      #     @foo = qux
      #   end
      #
      class ReturnInMemoizedContext < Base
        MSG = 'Do not return from within a memoized context.'

        # @!method memoized_return?(node)
        def_node_matcher :memoized_return?, <<~PATTERN
          (or_asgn (ivasgn _) (kwbegin <$`return ...>))
        PATTERN

        def on_or_asgn(node)
          return unless (return_node = memoized_return?(node))

          add_offense(return_node)
        end
      end
    end
  end
end
