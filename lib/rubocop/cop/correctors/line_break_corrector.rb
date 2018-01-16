# frozen_string_literal: true

module RuboCop
  module Cop
    # This class handles autocorrection for code that needs to be moved
    # to new lines.
    class LineBreakCorrector
      extend Alignment
      extend TrailingBody
      extend Util

      class << self
        attr_reader :processed_source

        def correct_trailing_body(configured_width:, corrector:, node:,
                                  processed_source:)
          @processed_source = processed_source
          range = first_part_of(node.to_a.last)
          eol_comment = end_of_line_comment(node.source_range.line)

          break_line_before(range: range, node: node, corrector: corrector,
                            configured_width: configured_width)
          move_comment(eol_comment: eol_comment, node: node,
                       corrector: corrector)
          remove_semicolon(node, corrector)
        end

        def break_line_before(range:, node:, corrector:, indent_steps: 1,
                              configured_width:)
          corrector.insert_before(
            range,
            "\n" + ' ' * (node.loc.keyword.column +
                          indent_steps * configured_width)
          )
        end

        def move_comment(eol_comment:, node:, corrector:)
          return unless eol_comment
          text = eol_comment.loc.expression.source
          corrector.insert_before(node.source_range,
                                  text + "\n" + (' ' * node.loc.keyword.column))
          corrector.remove(eol_comment.loc.expression)
        end

        private

        def remove_semicolon(node, corrector)
          return unless semicolon(node)
          corrector.remove(semicolon(node).pos)
        end

        def semicolon(node)
          @semicolon ||= {}
          @semicolon[node.object_id] ||= tokens(node).find(&:semicolon?)
        end
      end
    end
  end
end
