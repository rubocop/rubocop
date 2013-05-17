# encoding: utf-8

module Rubocop
  module Cop
    class PercentR < Cop
      MSG = 'Use %r only for regular expressions matching more ' +
        "than one '/' character."

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:regexp, sexp) do |node|
          if node.src.begin.to_source != '/' &&
              node.src.expression.to_source[1...-1].scan(/\//).size <= 1
            add_offence(:convention, node.src.line, MSG)
          end
        end
      end
    end
  end
end
