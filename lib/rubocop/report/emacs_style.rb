# encoding: utf-8

module Rubocop
  module Report
    # Plain text report, suitable for display in Emacs *compilation* buffers.
    class EmacsStyle < PlainText
      # Generates a string representation of the report
      def generate
        entries.map { |e|
          "#@filename:#{e.line_number+1}: #{e.encode_severity}: #{e.message}"
        }.join("\n")
      end
    end
  end
end
