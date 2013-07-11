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

          if loc.line != loc.colon.line
            add_offence(:convention, loc.expression, MSG)
          end
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
              if c.loc.respond_to?(:question)
                add_offence(:convention, c.loc.expression, MSG)
              end
            end
          end
        end
      end
    end
  end
end
