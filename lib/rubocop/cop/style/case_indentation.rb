# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether the *when*s of a *case* expression
      # are indented as deep as its *case* keyword.
      #
      # It will register a separate offence for each misaligned *when*.
      class CaseIndentation < Cop
        MSG = 'Indent when as deep as case.'

        def on_case(case_node)
          _condition, *whens, _else = *case_node

          case_column = case_node.location.keyword.column

          whens.each do |when_node|
            pos = when_node.loc.keyword
            convention(when_node, pos) if pos.column != case_column
          end
        end
      end
    end
  end
end
