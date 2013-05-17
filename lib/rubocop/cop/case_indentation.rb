# encoding: utf-8

module Rubocop
  module Cop
    class CaseIndentation < Cop
      MSG = 'Indent when as deep as case.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:case, sexp) do |case_node|
          _condition, *whens, _else = *case_node

          case_column = case_node.source_map.keyword.column
          whens.each do |when_node|
            pos = when_node.src.keyword
            if pos.column != case_column
              add_offence(:convention, pos.line, MSG)
            end
          end
        end
      end
    end
  end
end
