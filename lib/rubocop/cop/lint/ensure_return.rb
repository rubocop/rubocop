# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for `return` from an `ensure` block.
      # `return` from an ensure block is a dangerous code smell as it
      # will take precedence over any exception being raised,
      # and the exception will be silently thrown away as if it were rescued.
      #
      # If you want to rescue some (or all) exceptions, best to do it explicitly
      #
      # @example
      #
      #   # bad
      #   def foo
      #     do_something
      #   ensure
      #     cleanup
      #     return self
      #   end
      #
      #   # good
      #   def foo
      #     do_something
      #     self
      #   ensure
      #     cleanup
      #   end
      #
      #   # good
      #   def foo
      #     begin
      #       do_something
      #     rescue SomeException
      #       # Let's ignore this exception
      #     end
      #     self
      #   ensure
      #     cleanup
      #   end
      class EnsureReturn < Base
        MSG = 'Do not return from an `ensure` block.'

        def on_ensure(node)
          node.branch&.each_node(:return) do |return_node|
            next if return_from_inner_scope?(return_node, node)

            add_offense(return_node)
          end
        end

        private

        # A `return` inside a nested method definition or lambda within the
        # `ensure` returns from that inner scope, not from the method whose
        # `ensure` this is, so it is not an offense. A `return` inside a plain
        # block (or `proc`) does propagate out, so it remains an offense.
        def return_from_inner_scope?(return_node, ensure_node)
          return_node.each_ancestor do |ancestor|
            break if ancestor == ensure_node
            return true if ancestor.any_def_type? || (ancestor.any_block_type? && ancestor.lambda?)
          end
          false
        end
      end
    end
  end
end
