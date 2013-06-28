# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter formats report data in clang style.
    # The precise location of the problem is shown together with the
    # relevant source code.
    class DetailsFormatter < SimpleTextFormatter
      def report_file(file, offences)
        output.puts "== #{smart_path(file)} ==".color(:yellow)
        offences.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        File.basename(file), o.line, o.real_column,
                        o.encode_severity, o.message)
          output.puts(o.location.source_line)
          output.puts(' ' * o.location.column + '^', '')
        end
      end
    end
  end
end
