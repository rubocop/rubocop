# encoding: utf-8

module Rubocop
  module Cop
    class CaseIndentation < Cop
      ERROR_MESSAGE = 'Indent when as deep as case.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:case, sexp) do |case_node|
          _, *bodies = *case_node
          when_nodes = bodies[0..-2]

          case_column = case_node.source_map.keyword.column
          when_nodes.each do |when_node|
            pos = when_node.src.keyword
            if pos.column != case_column
              add_offence(:convention, pos.line, ERROR_MESSAGE)
            end
          end
        end
      end
    end
  end
end
