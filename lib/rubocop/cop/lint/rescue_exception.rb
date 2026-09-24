# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Checks for `rescue` blocks targeting the `Exception` class.
      #
      # In cases where re-raising is used as shown below, further exception handling is expected at
      # the caller, so no offense is registered.
      #
      # [source,ruby]
      # ----
      # begin
      #   do_something
      # rescue Exception
      #   handle_exception
      #   raise
      # end
      # ----
      #
      # @example
      #
      #   # bad
      #   begin
      #     do_something
      #   rescue Exception
      #     handle_exception
      #   end
      #
      #   # good
      #   begin
      #     do_something
      #   rescue ArgumentError
      #     handle_exception
      #   end
      class RescueException < Base
        MSG = 'Avoid rescuing the `Exception` class. Perhaps you meant to rescue `StandardError`?'

        def on_resbody(node)
          return unless node.exceptions.any? { |exception| targets_exception?(exception) }
          return if re_raise_in_resbody?(node)

          add_offense(node)
        end

        private

        def targets_exception?(rescue_arg_node)
          rescue_arg_node.const_name == 'Exception'
        end

        def re_raise_in_resbody?(node)
          node.each_descendant(:send).any? do |send_node|
            send_node.method?(:raise) || send_node.method?(:fail)
          end
        end
      end
    end
  end
end
