# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter formats report data in clang style.
    # The precise location of the problem is shown together with the
    # relevant source code.
    class ClangStyleFormatter < SimpleTextFormatter
      ELLIPSES = '...'

      def report_file(file, offenses)
        offenses.each { |offense| report_offense(file, offense) }
      end

      private

      def report_offense(file, offense)
        output.printf(
          "%<path>s:%<line>d:%<column>d: %<severity>s: %<message>s\n",
          path: cyan(smart_path(file)),
          line: offense.line,
          column: offense.real_column,
          severity: colored_severity_code(offense),
          message: message(offense)
        )

        begin
          return unless valid_line?(offense)

          report_line(offense.location)
          report_highlighted_area(offense.highlighted_area)
        rescue IndexError # rubocop:disable Lint/SuppressedException
          # range is not on a valid line; perhaps the source file is empty
        end
      end

      def valid_line?(offense)
        !offense.location.source_line.blank?
      end

      def report_line(location)
        source_line = location.source_line

        if location.first_line == location.last_line
          output.puts(source_line)
        else
          output.puts("#{source_line} #{yellow(ELLIPSES)}")
        end
      end

      def report_highlighted_area(highlighted_area)
        output.puts("#{' ' * highlighted_area.begin_pos}" \
                    "#{'^' * highlighted_area.size}")
      end
    end
  end
end
