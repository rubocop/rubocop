# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for nested ternary op expressions.
      class NestedTernaryOperator < Cop
        MSG = 'Ternary operators must not be nested. Prefer `if` or `else` ' \
              'constructs instead.'.freeze

        def on_if(node)
          return unless node.ternary?

          node.each_descendant(:if).select(&:ternary?).each do |nested_ternary|
            add_offense(nested_ternary, :expression)
          end
        end
      end
    end
  end
end
