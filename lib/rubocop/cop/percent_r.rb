# encoding: utf-8

module Rubocop
  module Cop
    class PercentR < Cop
      ERROR_MESSAGE = 'Use %r only for regular expressions matching more ' +
        "than one '/' character."

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:regexp, sexp) do |node|
          if node.src.begin.to_source != '/' &&
              node.src.expression.to_source[1...-1] !~ %r(/.*/)
            add_offence(:convention, node.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
