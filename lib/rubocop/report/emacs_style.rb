# encoding: utf-8

module Rubocop
  module Report
    # Plain text report, suitable for display in Emacs *compilation* buffers.
    class EmacsStyle < PlainText
      # Generates a string representation of the report
      def generate
        report = entries.map do |e|
          sprintf('%s:%d: %s: %s', @filename,
                  e.line_number, e.encode_severity, e.message)
        end
        report.join("\n")
      end
    end
  end
end
