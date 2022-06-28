# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Checks that strings broken over multiple lines (by a backslash) contain
      # trailing spaces instead of leading spaces (default) or leading spaces
      # instead of trailing spaces.
      #
      # @example EnforcedStyle: trailing (default)
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
      # @example EnforcedStyle: leading
      #   # bad
      #   'this text contains a lot of               ' \
      #   'spaces'
      #
      #   # good
      #   'this text contains a lot of' \
      #   '               spaces'
      #
      #   # bad
      #   'this text is too ' \
      #   'long'
      #
      #   # good
      #   'this text is too' \
      #   ' long'
      class LineContinuationLeadingSpace < Base
        include RangeHelp

        def on_dstr(node)
          end_of_first_line = node.loc.expression.begin_pos - node.loc.expression.column

          raw_lines(node).each_cons(2) do |raw_line_one, raw_line_two|
            end_of_first_line += raw_line_one.length

            next unless continuation?(raw_line_one)

            if enforced_style_leading?
              investigate_leading_style(raw_line_one, end_of_first_line)
            else
              investigate_trailing_style(raw_line_two, end_of_first_line)
            end
          end
        end

        private

        def raw_lines(node)
          processed_source.raw_source.lines[node.first_line - 1, line_range(node).size]
        end

        def investigate_leading_style(first_line, end_of_first_line)
          matches = first_line.match(/(?<trailing_spaces>\s+)(?<ending>['"]\s*\\\n)/)
          return if matches.nil?

          add_offense(leading_offense_range(end_of_first_line, matches))
        end

        def investigate_trailing_style(second_line, end_of_first_line)
          matches = second_line.match(/\A(?<beginning>\s*['"])(?<leading_spaces>\s+)/)
          return if matches.nil?

          add_offense(trailing_offense_range(end_of_first_line, matches))
        end

        def continuation?(line)
          line.end_with?("\\\n")
        end

        def leading_offense_range(end_of_first_line, matches)
          end_pos = end_of_first_line - matches[:ending].length
          begin_pos = end_pos - matches[:trailing_spaces].length
          range_between(begin_pos, end_pos)
        end

        def trailing_offense_range(end_of_first_line, matches)
          begin_pos = end_of_first_line + matches[:beginning].length
          end_pos = begin_pos + matches[:leading_spaces].length
          range_between(begin_pos, end_pos)
        end

        def message(_range)
          if enforced_style_leading?
            'Move trailing spaces to the start of next line.'
          else
            'Move leading spaces to the end of previous line.'
          end
        end

        def enforced_style_leading?
          cop_config['EnforcedStyle'] == 'leading'
        end
      end
    end
  end
end
