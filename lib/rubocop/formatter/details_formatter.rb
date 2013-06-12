# encoding: utf-8

module Rubocop
  module Formatter
    class DetailsFormatter < SimpleTextFormatter
      def report_file(file, offences)
        output.puts "== #{file} ==".color(:yellow)
        offences.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        File.basename(file), o.line, o.column,
                        o.encode_severity, o.message)
          output.puts(o.source_line)
          output.puts(' ' * o.location.column + '^', '')
        end
      end
    end
  end
end
