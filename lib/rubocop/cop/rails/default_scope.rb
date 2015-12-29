# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop checks for default_scope calls when it was passed
      # a lambda or a proc instead of a block.
      #
      # @example
      #
      #   # incorrect
      #   default_scope -> { something }
      #
      #   # correct
      #   default_scope { something }
      class DefaultScope < Cop
        MSG = '`default_scope` expects a block as its sole argument.'

        def on_send(node)
          return unless node.command?(:default_scope)

          _receiver, _method_name, *args = *node
          return unless args.size == 1

          first_arg = args[0]
          return unless first_arg.type != :block || first_arg.lambda_or_proc?

          add_offense(first_arg, :expression)
        end
      end
    end
  end
end
