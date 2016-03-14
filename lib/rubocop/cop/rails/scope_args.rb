# encoding: utf-8
# frozen_string_literal: true

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
        MSG = 'Use `lambda`/`proc` instead of a plain method call.'.freeze

        def on_send(node)
          return unless node.command?(:scope)

          _receiver, _method_name, *args = *node

          return unless args.size == 2

          second_arg = args[1]

          if second_arg.type == :send && !lambda_send?(second_arg)
            add_offense(second_arg, :expression)
          end
        end

        private

        def lambda_send?(node)
          receiver, selector = *node

          receiver.nil? && selector == :lambda
        end
      end
    end
  end
end
