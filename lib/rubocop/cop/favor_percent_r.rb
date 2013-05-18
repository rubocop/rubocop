# encoding: utf-8

module Rubocop
  module Cop
    class FavorPercentR < Cop
      MSG = 'Use %r for regular expressions matching more ' +
        "than one '/' character."

      def inspect(file, source, tokens, sexp)
        on_node(:regexp, sexp) do |node|
          if node.src.begin.to_source == '/' &&
              node.src.expression.to_source[1...-1].scan(/\//).size > 1
            add_offence(:convention, node.src.line, MSG)
          end
        end
      end
    end
  end
end
