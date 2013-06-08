# encoding: utf-8

module Rubocop
  module Cop
    class VoidOp < Cop
      MSG = 'Possible use of operator %s in void context.'

      OPS = %w(* / % + - == === != < > <= >= <=>)

      def on_begin(node)
        expressions = *node

        expressions[0...-1].each do |expr|
          if expr.type == :send && OPS.include?(expr.loc.selector.source)
            add_offence(:warning,
                        expr.loc.selector,
                        sprintf(MSG, expr.loc.selector.source))
          end
        end

        super
      end
    end
  end
end
