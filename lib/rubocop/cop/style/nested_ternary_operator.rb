# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for nested ternary op expressions.
      #
      # @example
      #   # bad
      #   a ? (b ? b1 : b2) : a2
      #
      #   # good
      #   if a
      #     b ? b1 : b2
      #   else
      #     a2
      #   end
      class NestedTernaryOperator < Cop
        MSG = 'Ternary operators must not be nested. Prefer `if` or `else` ' \
              'constructs instead.'.freeze

        def on_if(node)
          return unless node.ternary?

          node.each_descendant(:if).select(&:ternary?).each do |nested_ternary|
            add_offense(nested_ternary)
          end
        end
      end
    end
  end
end
