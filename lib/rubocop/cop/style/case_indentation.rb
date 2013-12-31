# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks how the *when*s of a *case* expression
      # are indented in relation to its *case* or *end* keyword.
      #
      # It will register a separate offence for each misaligned *when*.
      class CaseIndentation < Cop
        include ConfigurableEnforcedStyle

        def on_case(case_node)
          _condition, *whens, _else = *case_node

          base = style
          indent = cop_config['IndentOneStep']
          base_column = base_column(case_node, base)

          whens.each do |when_node|
            check_when(when_node, case_node, base, indent, base_column)
          end
        end

        private

        def check_when(when_node, case_node, base, indent, base_column)
          pos = when_node.loc.keyword
          expected_column = base_column +
            (indent ? IndentationWidth::CORRECT_INDENTATION : 0)
          if pos.column == expected_column
            correct_style_detected
          else
            msg = 'Indent when ' + if indent
                                     "one step more than #{base}."
                                   else
                                     "as deep as #{base}."
                                   end
            add_offence(when_node, pos, msg) do
              if pos.column == base_column(case_node, alternative_style)
                opposite_style_detected
              else
                unrecognized_style_detected
              end
            end
          end
        end

        def parameter_name
          'IndentWhenRelativeTo'
        end

        def base_column(case_node, base)
          case base
          when :case then case_node.location.keyword.column
          when :end  then case_node.location.end.column
          end
        end
      end
    end
  end
end
