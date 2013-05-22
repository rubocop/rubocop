# encoding: utf-8

module Rubocop
  module Cop
    class CaseIndentation < Cop
      MSG = 'Indent when as deep as case.'

      def on_case(case_node)
        _condition, *whens, _else = *case_node

        case_column = case_node.source_map.keyword.column

        whens.each do |when_node|
          pos = when_node.src.keyword
          add_offence(:convention, pos.line, MSG) if pos.column != case_column
        end

        super
      end
    end
  end
end
