# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for `raise` or `fail` statements which are
      # raising `Exception` class.
      #
      # @example
      #   # bad
      #   raise Exception, 'Error message here'
      #
      #   # good
      #   raise StandardError, 'Error message here'
      class RaiseException < Cop
        MSG = 'Use `StandardError` over `Exception`.'

        def_node_matcher :exception?, <<~PATTERN
          (send nil? ${:raise :fail} (const _ :Exception) ... )
        PATTERN

        def_node_matcher :exception_new_with_message?, <<~PATTERN
          (send nil? ${:raise :fail}
            (send (const _ :Exception) :new ... ))
        PATTERN

        def on_send(node)
          add_offense(node) if raise_exception?(node)
        end

        private

        def raise_exception?(node)
          exception?(node) || exception_new_with_message?(node)
        end
      end
    end
  end
end
