# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for *return* from an *ensure* block.
      #
      # @example
      #
      #   # bad
      #
      #   begin
      #     do_something
      #   ensure
      #     do_something_else
      #     return
      #   end
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     do_something
      #   ensure
      #     do_something_else
      #   end
      class EnsureReturn < Cop
        MSG = 'Do not return from an `ensure` block, it changes the control ' \
              'flow as if a `rescue Exception` clause was in place before ' \
              'the `ensure` clause.'.freeze

        def on_ensure(node)
          ensure_body = node.body

          return unless ensure_body

          ensure_body.each_node(:return) do |return_node|
            add_offense(return_node)
          end
        end
      end
    end
  end
end
