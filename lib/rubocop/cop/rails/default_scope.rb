# encoding: utf-8

module Rubocop
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
        MSG = 'default_scope expects a block as its sole argument.'

        def on_send(node)
          return unless command?(:default_scope, node)

          _receiver, _method_name, *args = *node

          return unless args.size == 1

          first_arg = args[0]

          if first_arg.type != :block || lambda_or_proc?(first_arg)
            add_offence(first_arg, :expression)
          end
        end
      end
    end
  end
end
