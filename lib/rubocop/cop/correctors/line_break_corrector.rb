# frozen_string_literal: true

module RuboCop
  module Cop
    # This class handles autocorrection for code that needs to be moved
    # to new lines.
    class LineBreakCorrector
      class << self
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
      end
    end
  end
end
