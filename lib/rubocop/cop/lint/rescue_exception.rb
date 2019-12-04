# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for *rescue* blocks targeting the Exception class.
      #
      # @example
      #
      #   # bad
      #
      #   begin
      #     do_something
      #   rescue Exception
      #     handle_exception
      #   end
      #
      # @example
      #
      #   # good
      #
      #   begin
      #     do_something
      #   rescue ArgumentError
      #     handle_exception
      #   end
      class RescueException < Cop
        MSG = 'Avoid rescuing the `Exception` class. ' \
              'Perhaps you meant to rescue `StandardError`?'

        def_node_matcher :raise?, <<~PATTERN
          (send nil? :raise)
        PATTERN

        def on_resbody(node)
          return unless node.children.first

          begin_body = node.children.last
          return if begin_body && re_raised?(begin_body.children)

          rescue_args = node.children.first.children
          return unless rescue_args.any? { |a| targets_exception?(a) }

          add_offense(node)
        end

        private

        def re_raised?(children)
          children.reverse.any? { |a| raise?(a) }
        end

        def targets_exception?(rescue_arg_node)
          rescue_arg_node.const_name == 'Exception'
        end
      end
    end
  end
end
