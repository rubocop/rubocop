# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for RuntimeError as the argument of raise/fail.
      #
      # Currently it checks for code like this:
      #
      # @example
      #
      #   raise RuntimeError, 'message'
      class RedundantException < Cop
        MSG = 'Redundant `RuntimeError` argument can be removed.'

        TARGET_NODE = s(:const, nil, :RuntimeError)

        def on_send(node)
          return unless command?(:raise, node) || command?(:fail, node)

          _receiver, _selector, *args = *node

          return unless args.size == 2

          first_arg, = *args

          add_offence(first_arg, :expression) if first_arg == TARGET_NODE
        end
      end
    end
  end
end
