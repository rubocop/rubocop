# encoding: utf-8

module Rubocop
  module Formatter
    class EmacsStyleFormatter < PlainTextFormatter
      def report_file(file, offences)
        offences.each do |o|
          output.printf("%s:%d: %s: %s\n",
                        file, o.line_number, o.encode_severity, o.message)
        end
      end
    end
  end
end
