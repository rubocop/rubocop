# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks how the *when*s of a *case* expression
      # are indented in relation to its *case* or *end* keyword.
      #
      # It will register a separate offence for each misaligned *when*.
      class CaseIndentation < Cop
        def on_case(case_node)
          _condition, *whens, _else = *case_node

          base, indent = cop_config.values_at('IndentWhenRelativeTo',
                                              'IndentOneStep')
          base_column = base_column(case_node, base)

          whens.each do |when_node|
            pos = when_node.loc.keyword
            expected_column = base_column +
              (indent ? IndentationWidth::CORRECT_INDENTATION : 0)
            if pos.column != expected_column
              msg = 'Indent when ' + if indent
                                       "one step more than #{base}."
                                     else
                                       "as deep as #{base}."
                                     end
              convention(when_node, pos, msg)
            end
          end
        end

        private

        def base_column(case_node, base)
          case base
          when 'case' then case_node.location.keyword.column
          when 'end'  then case_node.location.end.column
          else fail "Unknown IndentWhenRelativeTo: #{base}"
          end
        end
      end
    end
  end
end
