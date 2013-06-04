# encoding: utf-8

module Rubocop
  module Cop
    class WhenThen < Cop
      MSG = 'Never use "when x;". Use "when x then" instead.'

      def on_when(node)
        if node.loc.begin && node.loc.begin.source == ';'
          add_offence(:convention, node.loc, MSG)
        end

        super
      end
    end
  end
end
