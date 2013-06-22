# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter displays the report data in format that's
    # easy to process in the Emacs text editor.
    class EmacsStyleFormatter < SimpleTextFormatter
      def report_file(file, offences)
        offences.each do |o|
          output.printf("%s:%d:%d: %s: %s\n",
                        file, o.line, o.column + 1, o.encode_severity,
                        o.message)
        end
      end
    end
  end
end
