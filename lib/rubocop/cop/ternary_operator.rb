# encoding: utf-8

module Rubocop
  module Cop
    class MultilineTernaryOperator < Cop
      MSG =
        'Avoid multi-line ?: (the ternary operator); use if/unless instead.'

      def on_if(node)
        loc = node.loc

        # discard non-ternary ops
        return unless loc.respond_to?(:question)

        add_offence(:convention, loc, MSG) if loc.line != loc.colon.line

        super
      end
    end

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
              add_offence(:convention, c.loc, MSG)
            end
          end
        end

        super
      end
    end
  end
end
