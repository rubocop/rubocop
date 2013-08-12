# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter formats report data in clang style.
    # The precise location of the problem is shown together with the
    # relevant source code.
    class ClangStyleFormatter < SimpleTextFormatter
      def report_file(file, offences)
        offences.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        smart_path(file).color(:cyan), o.line, o.real_column,
                        o.clang_severity, o.message)

          source_line = o.location.source_line

          unless source_line.blank?
            output.puts(source_line)
            output.puts(' ' * o.location.column +
                        '^' * o.location.column_range.count)
          end
        end
      end
    end
  end
end
