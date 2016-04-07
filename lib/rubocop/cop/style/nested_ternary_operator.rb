# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for nested ternary op expressions.
      class NestedTernaryOperator < Cop
        include IfNode

        MSG = 'Ternary operators must not be nested. Prefer `if` or `else` ' \
              'constructs instead.'.freeze

        def on_if(node)
          return unless ternary?(node)

          node.each_descendant(:if) do |nested_if_node|
            add_offense(nested_if_node, :expression) if ternary?(nested_if_node)
          end
        end
      end
    end
  end
end
