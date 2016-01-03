# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter formats report data in clang style.
    # The precise location of the problem is shown together with the
    # relevant source code.
    class ClangStyleFormatter < SimpleTextFormatter
      def report_file(file, offenses)
        offenses.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        cyan(smart_path(file)), o.line, o.real_column,
                        colored_severity_code(o), message(o))

          source_line = o.location.source_line
          next if source_line.blank?

          output.puts(source_line)
          output.puts(highlight_line(o.location))
        end
      end

      def highlight_line(location)
        column_length = if location.begin.line == location.end.line
                          location.column_range.count
                        else
                          location.source_line.length - location.column
                        end

        ' ' * location.column + '^' * column_length
      end
    end
  end
end
