# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class CaseIndentation < Cop
        MSG = 'Indent when as deep as case.'

        def on_case(case_node)
          _condition, *whens, _else = *case_node

          case_column = case_node.location.keyword.column

          whens.each do |when_node|
            pos = when_node.loc.keyword
            add_offence(:convention, pos, MSG) if pos.column != case_column
          end

          super
        end
      end
    end
  end
end
