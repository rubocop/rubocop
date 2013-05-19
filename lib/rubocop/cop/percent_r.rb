# encoding: utf-8

module Rubocop
  module Cop
    class PercentR < Cop
      MSG = 'Use %r only for regular expressions matching more ' +
        "than one '/' character."

      def inspect(file, source, tokens, ast)
        on_node(:regexp, ast) do |node|
          if node.src.begin.to_source != '/' &&
              node.src.expression.to_source[1...-1].scan(/\//).size <= 1
            add_offence(:convention, node.src.line, MSG)
          end
        end
      end
    end
  end
end
