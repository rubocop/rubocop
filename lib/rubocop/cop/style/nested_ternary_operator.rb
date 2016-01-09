# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for nested ternary op expressions.
      class NestedTernaryOperator < Cop
        MSG = 'Ternary operators must not be nested. Prefer `if`/`else` ' \
              'constructs instead.'.freeze

        def on_if(node)
          loc = node.loc

          # discard non-ternary ops
          return unless loc.respond_to?(:question)

          node.each_descendant(:if) do |nested_if_node|
            if nested_if_node.loc.respond_to?(:question)
              add_offense(nested_if_node, :expression)
            end
          end
        end
      end
    end
  end
end
