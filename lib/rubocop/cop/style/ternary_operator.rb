# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for multi-line ternary op expressions.
      class MultilineTernaryOperator < Cop
        MSG =
          'Avoid multi-line ?: (the ternary operator); use if/unless instead.'

        def on_if(node)
          loc = node.loc

          # discard non-ternary ops
          return unless loc.respond_to?(:question)

          convention(node, :expression) if loc.line != loc.colon.line
        end
      end

      # This cop checks for nested ternary op expressions.
      class NestedTernaryOperator < Cop
        MSG = 'Ternary operators must not be nested. Prefer if/else ' +
            'constructs instead.'

        def on_if(node)
          loc = node.loc

          # discard non-ternary ops
          return unless loc.respond_to?(:question)

          node.children.each do |child|
            on_node(:if, child) do |c|
              convention(c, :expression) if c.loc.respond_to?(:question)
            end
          end
        end
      end
    end
  end
end
