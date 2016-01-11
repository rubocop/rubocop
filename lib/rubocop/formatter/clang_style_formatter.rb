# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter formats report data in clang style.
    # The precise location of the problem is shown together with the
    # relevant source code.
    class ClangStyleFormatter < SimpleTextFormatter
      ELLIPSES = Rainbow('...').yellow.freeze

      def report_file(file, offenses)
        offenses.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        cyan(smart_path(file)), o.line, o.real_column,
                        colored_severity_code(o), message(o))

          # rubocop:disable Lint/HandleExceptions
          begin
            location = o.location
            source_line = location.source_line
            next if source_line.blank?

            if location.first_line == location.last_line
              column_length = location.column_range.count
              output.puts(source_line)
            else
              column_length = location.source_line.length - location.column
              output.puts("#{source_line} #{ELLIPSES}")
            end
            output.puts("#{' ' * location.column}#{'^' * column_length}")
          rescue IndexError
            # range is not on a valid line; perhaps the source file is empty
          end
          # rubocop:enable Lint/HandleExceptions
        end
      end
    end
  end
end
