# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Access modifiers should be surrounded by blank lines.
      class EmptyLinesAroundAccessModifier < Cop
        include AccessModifierNode

        MSG = 'Keep a blank line after `%s`. And before, '\
              'if it is not first line of module.'.freeze

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
            line = line_range(node)

            unless previous_line_empty?(previous_line)
              corrector.insert_before(line, "\n")
            end

            unless next_line_empty?(next_line)
              corrector.insert_after(line, "\n")
            end
          end
        end

        private

        def line_range(node)
          range_between(node.source_range.begin_pos - node.loc.column,
                        node.source_range.end_pos)
        end

        def previous_line_ignoring_comments(processed_source, send_line)
          processed_source[0..send_line - 2].reverse.find do |line|
            !comment_line?(line)
          end
        end

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
          previous_line = previous_line_ignoring_comments(processed_source,
                                                          send_line)
          next_line = processed_source[send_line]

          previous_line_empty?(previous_line) && next_line_empty?(next_line)
        end

        def class_def?(line)
          line.start_with?('class', 'module')
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
