# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for *rescue* blocks targeting the Exception class.
      class RescueException < Cop
        MSG = 'Avoid rescuing the `Exception` class. ' \
              'Perhaps you meant to rescue `StandardError`?'

        def on_resbody(node)
          return unless node.children.first
          rescue_args = node.children.first.children
          return unless rescue_args.any? { |a| targets_exception?(a) }

          add_offense(node, :expression)
        end

        def targets_exception?(rescue_arg_node)
          Util.const_name(rescue_arg_node) == 'Exception'
        end
      end
    end
  end
end
