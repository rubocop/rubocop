# encoding: utf-8

module Rubocop
  module Cop
    class WhenThen < Cop
      MSG = 'Never use "when x;". Use "when x then" instead.'

      def on_when(node)
        if node.src.begin && node.src.begin.to_source == ';'
          add_offence(:convention, node.src.line, MSG)
        end

        super
      end
    end
  end
end
