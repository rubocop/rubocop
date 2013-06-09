# encoding: utf-8

module Rubocop
  module Cop
    class UnreachableCode < Cop
      MSG = 'Unreachable code detected.'

      def on_begin(node)
        expressions = *node

        expressions.each_cons(2) do |e1, e2|
          add_offence(:warning, e2.loc.expression, MSG) if e1.type == :return
        end

        super
      end
    end
  end
end
