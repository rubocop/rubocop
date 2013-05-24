# encoding: utf-8

module Rubocop
  module Cop
    class FavorPercentR < Cop
      MSG = 'Use %r for regular expressions matching more ' +
        "than one '/' character."

      def on_regexp(node)
        if node.src.begin.to_source == '/' &&
            node.src.expression.to_source[1...-1].scan(/\//).size > 1
          add_offence(:convention, node.src.line, MSG)
        end

        super
      end
    end
  end
end
