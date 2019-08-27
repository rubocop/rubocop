# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop looks for *unless* with conditionals including operators.
      #
      # @example
      #   # bad
      #   return false unless foo && bar
      #
      #   # good
      #   return false unless foo
      #   return false unless bar
      class UnlessWithOperator < Cop
        MSG = 'Do not use `unless` with operator. Split this over several ' \
              'lines.'

        def on_if(node)
          return unless node.unless?
          return unless node.condition.respond_to?(:operator)

          add_offense(node)
        end
      end
    end
  end
end
