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
          if o.location.respond_to?(:expression)
            output.puts(o.location.expression.source_line)
          else
            output.puts(o.location.source_line)
          end
          output.puts(' ' * o.location.column + '^', '')
        end
      end
    end
  end
end
