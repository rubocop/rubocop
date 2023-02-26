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
        extend AutoCorrector

        LINE_1_ENDING = /['"]\s*\\\n/.freeze
        LINE_2_BEGINNING = /\A\s*['"]/.freeze
        LEADING_STYLE_OFFENSE = /(?<trailing_spaces>\s+)(?<ending>#{LINE_1_ENDING})/.freeze
        TRAILING_STYLE_OFFENSE = /(?<beginning>#{LINE_2_BEGINNING})(?<leading_spaces>\s+)/.freeze
        private_constant :LINE_1_ENDING, :LINE_2_BEGINNING,
                         :LEADING_STYLE_OFFENSE, :TRAILING_STYLE_OFFENSE

        def on_dstr(node)
          # Quick check if we possibly have line continuations.
          return unless node.source.include?('\\')

          end_of_first_line = node.source_range.begin_pos - node.source_range.column

          raw_lines(node).each_cons(2) do |raw_line_one, raw_line_two|
            end_of_first_line += raw_line_one.length

            next unless continuation?(raw_line_one)

            if enforced_style_leading?
              investigate_leading_style(raw_line_one, raw_line_two, end_of_first_line)
            else
              investigate_trailing_style(raw_line_one, raw_line_two, end_of_first_line)
            end
          end
        end

        private

        def raw_lines(node)
          processed_source.raw_source.lines[node.first_line - 1, line_range(node).size]
        end

        def investigate_leading_style(first_line, second_line, end_of_first_line)
          matches = first_line.match(LEADING_STYLE_OFFENSE)
          return if matches.nil?

          offense_range = leading_offense_range(end_of_first_line, matches)
          add_offense(offense_range) do |corrector|
            insert_pos = end_of_first_line + second_line[LINE_2_BEGINNING].length
            autocorrect(corrector, offense_range, insert_pos, matches[:trailing_spaces])
          end
        end

        def investigate_trailing_style(first_line, second_line, end_of_first_line)
          matches = second_line.match(TRAILING_STYLE_OFFENSE)
          return if matches.nil?

          offense_range = trailing_offense_range(end_of_first_line, matches)
          add_offense(offense_range) do |corrector|
            insert_pos = end_of_first_line - first_line[LINE_1_ENDING].length
            autocorrect(corrector, offense_range, insert_pos, matches[:leading_spaces])
          end
        end

        def continuation?(line)
          line.end_with?("\\\n")
        end

        def autocorrect(corrector, offense_range, insert_pos, spaces)
          corrector.remove(offense_range)
          corrector.replace(range_between(insert_pos, insert_pos), spaces)
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
