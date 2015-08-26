# encoding: utf-8

module RuboCop
  module Cop
    module Rails
      # This cop checks for scope calls where it was passed
      # a method (usually a scope) instead of a lambda/proc.
      #
      # @example
      #
      #   # bad
      #   scope :something, where(something: true)
      #
      #   # good
      #   scope :something, -> { where(something: true) }
      class ScopeArgs < Cop
        MSG = 'Use `lambda`/`proc` instead of a plain method call.'

        def on_send(node)
          return unless command?(:scope, node)

          _receiver, _method_name, *args = *node

          return unless args.size == 2

          second_arg = args[1]
          return unless second_arg.type == :send && !lambda?(second_arg)

          add_offense(second_arg, :expression)
        end

        private

        def lambda?(send_node)
          receiver_node, selector_node = *send_node
          receiver_node.nil? && selector_node == :lambda
        end
      end
    end
  end
end
