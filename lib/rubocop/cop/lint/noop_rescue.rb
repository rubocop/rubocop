# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Check for suppress or ignore checked exception.
      #
      # @example
      #   # bad
      #   foo rescue nil
      #
      #   # bad
      #   def foo
      #     do_something
      #   rescue StandardError => e
      #     # no op
      #   end
      #
      #   # good
      #   foo rescue do_something
      #
      #   # good
      #   def foo
      #     do_something
      #   rescue StandardError => e
      #     do_something
      #   end
      #
      class NoopRescue < Base
        MSG = "Don't suppress or ignore checked exception."

        # @!method send_node_include?(node)
        def_node_search :send_node_include?, <<~PATTERN
          (send ...)
        PATTERN

        def on_resbody(node)
          add_offense(node) if noop?(node.body)
        end

        private

        def noop?(node)
          return true unless node

          !send_node_include?(node)
        end
      end
    end
  end
end
