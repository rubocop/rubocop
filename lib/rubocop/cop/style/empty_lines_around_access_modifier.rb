# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Access modifiers should be surrounded by blank lines.
      class EmptyLinesAroundAccessModifier < Cop
        include AccessModifierNode

        MSG = 'Keep a blank line before and after `%s`.'

        def on_send(node)
          return unless modifier_node?(node)

          return if empty_lines_around?(node)

          add_offense(node, :expression)
        end

        def autocorrect(node)
          lambda do |corrector|
            send_line = node.loc.line
            previous_line = processed_source[send_line - 2]
            next_line = processed_source[send_line]

            line = Parser::Source::Range.new(
              processed_source.buffer,
              node.loc.expression.begin_pos - node.loc.column,
              node.loc.expression.end_pos
            )

            unless previous_line_empty?(previous_line)
              corrector.insert_before(line, "\n")
            end

            unless next_line_empty?(next_line)
              corrector.insert_after(line, "\n")
            end
          end
        end

        private

        def previous_line_empty?(previous_line)
          block_start?(previous_line.lstrip) ||
            class_def?(previous_line.lstrip) ||
            previous_line.blank?
        end

        def next_line_empty?(next_line)
          body_end?(next_line.lstrip) || next_line.blank?
        end

        def empty_lines_around?(node)
          send_line = node.loc.line
          previous_line = processed_source[send_line - 2]
          next_line = processed_source[send_line]

          previous_line_empty?(previous_line) && next_line_empty?(next_line)
        end

        def class_def?(line)
          %w(class module).any? { |keyword| line.start_with?(keyword) }
        end

        def block_start?(line)
          line.match(/ (do|{)( \|.*?\|)?\s?$/)
        end

        def body_end?(line)
          line.start_with?('end')
        end

        def message(node)
          format(MSG, node.loc.selector.source)
        end
      end
    end
  end
end
