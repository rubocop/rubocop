# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter displays the report data in format that's
    # easy to process in the Emacs text editor.
    class EmacsStyleFormatter < BaseFormatter
      def file_finished(file, offences)
        offences.each do |o|
          message = o.corrected? ? '[Corrected] ' : ''
          message << o.message

          output.printf("%s:%d:%d: %s: %s\n",
                        file, o.line, o.real_column, o.severity_code,
                        message)
        end
      end
    end
  end
end
