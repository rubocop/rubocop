# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for the presence of a `return` inside a `begin..end` block
      # in assignment contexts.
      # In this situation, the `return` will result in an exit from the current
      # method, possibly leading to unexpected behavior.
      #
      # @example
      #
      #   # bad
      #   @some_variable ||= begin
      #     return some_value if some_condition_is_met
      #
      #     do_something
      #   end
      #
      #   # good
      #   @some_variable ||= begin
      #     if some_condition_is_met
      #       some_value
      #     else
      #       do_something
      #     end
      #   end
      #
      #   # good
      #   some_variable = if some_condition_is_met
      #                     return if another_condition_is_met
      #
      #                     some_value
      #                   else
      #                     do_something
      #                   end
      #
      class NoReturnInBeginEndBlocks < Base
        MSG = 'Do not `return` in `begin..end` blocks in assignment contexts.'

        def on_lvasgn(node)
          node.each_node(:kwbegin) do |kwbegin_node|
            kwbegin_node.each_node(:return) do |return_node|
              next if return_from_inner_scope?(return_node, kwbegin_node)

              add_offense(return_node)
            end
          end
        end
        alias on_ivasgn on_lvasgn
        alias on_cvasgn on_lvasgn
        alias on_gvasgn on_lvasgn
        alias on_casgn on_lvasgn
        alias on_or_asgn on_lvasgn
        alias on_op_asgn on_lvasgn

        private

        # A `return` inside a nested method definition or lambda within the
        # `begin..end` returns from that inner scope rather than the assignment
        # context, so it is not an offense. A `return` inside a plain block (or
        # `proc`) does propagate out, so it remains an offense.
        def return_from_inner_scope?(return_node, kwbegin_node)
          return_node.each_ancestor do |ancestor|
            break if ancestor == kwbegin_node
            return true if ancestor.any_def_type? || (ancestor.any_block_type? && ancestor.lambda?)
          end
          false
        end
      end
    end
  end
end
