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
      #
      #   @some_variable ||= begin
      #     return some_value if some_condition_is_met
      #
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   @some_variable ||= begin
      #     if some_condition_is_met
      #       some_value
      #     else
      #       do_something
      #     end
      #   end
      #
      #   # good
      #
      #   some_variable = if some_condition_is_met
      #                     return if another_condition_is_met
      #
      #                     some_value
      #                   else
      #                     do_something
      #                   end
      #
      class NoReturnInBeginEndBlocks < Cop
        MSG = 'Do not `return` in `begin..end` blocks in assignment contexts.'

        def on_lvasgn(node)
          return unless node.begin_type?

          node.each_node(:return) do |return_node|
            add_offense(return_node)
          end
        end

        def on_or_asgn(node)
          node.each_node(:kwbegin) do |kwbegin_node|
            kwbegin_node.each_node(:return) do |return_node|
              add_offense(return_node)
            end
          end
        end
      end
    end
  end
end
