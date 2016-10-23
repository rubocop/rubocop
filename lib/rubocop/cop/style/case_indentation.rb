# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks how the *when*s of a *case* expression
      # are indented in relation to its *case* or *end* keyword.
      #
      # It will register a separate offense for each misaligned *when*.
      class CaseIndentation < Cop
        include AutocorrectAlignment
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
                            (indent ? configured_indentation_width : 0)
          if pos.column == expected_column
            correct_style_detected
          else
            incorrect_style(when_node, case_node, base, pos, indent)
          end
        end

        def incorrect_style(when_node, case_node, base, pos, indent)
          msg = 'Indent `when` ' + if indent
                                     "one step more than `#{base}`."
                                   else
                                     "as deep as `#{base}`."
                                   end
          add_offense(when_node, pos, msg) do
            if pos.column == base_column(case_node, alternative_style)
              opposite_style_detected
            else
              unrecognized_style_detected
            end
          end
        end

        def base_column(case_node, base)
          case base
          when :case then case_node.location.keyword.column
          when :end  then case_node.location.end.column
          end
        end

        def autocorrect(node)
          whitespace = whitespace_range(node)
          return false unless whitespace.source.strip.empty?

          ->(corrector) { corrector.replace(whitespace, replacement(node)) }
        end

        def whitespace_range(node)
          when_column = node.location.keyword.column
          begin_pos = node.loc.keyword.begin_pos

          range_between(begin_pos - when_column, begin_pos)
        end

        def replacement(node)
          case_node = node.each_ancestor(:case).first
          base_type = cop_config[style_parameter_name] == 'end' ? :end : :case
          column = base_column(case_node, base_type)
          column += configured_indentation_width if cop_config['IndentOneStep']
          ' ' * column
        end
      end
    end
  end
end
