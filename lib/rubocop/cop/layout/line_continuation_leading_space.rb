# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that strings broken over multiple lines (by a backslash) contain
      # trailing spaces instead of leading spaces.
      #
      # @example
      #   # bad
      #   'this text contains a lot of' \
      #   '               spaces'
      #
      #   # good
      #   'this text contains a lot of               ' \
      #   'spaces'
      #
      #   # bad
      #   'this text is too' \
      #   ' long'
      #
      #   # good
      #   'this text is too ' \
      #   'long'
      #
      class LineContinuationLeadingSpace < Base
        include RangeHelp

        MSG = 'Move leading spaces to the end of previous line.'

        def on_dstr(node)
          range_start = node.loc.expression.begin_pos - node.loc.expression.column

          raw_lines(node).each_cons(2) do |raw_line_one, raw_line_two|
            range_start += raw_line_one.length

            investigate(raw_line_one, raw_line_two, range_start)
          end
        end

        private

        def raw_lines(node)
          processed_source.raw_source.lines[node.first_line - 1, line_range(node).size]
        end

        def investigate(first_line, second_line, range_start)
          return unless continuation?(first_line)

          matches = second_line.match(/\A(?<indent>\s*['"])(?<leading_spaces>\s+)/)
          return if matches.nil?

          add_offense(offense_range(range_start, matches))
        end

        def continuation?(line)
          line.end_with?("\\\n")
        end

        def offense_range(range_start, matches)
          begin_pos = range_start + matches[:indent].length
          end_pos = begin_pos + matches[:leading_spaces].length
          range_between(begin_pos, end_pos)
        end
      end
    end
  end
end
