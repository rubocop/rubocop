# encoding: utf-8

module Rubocop
  module Report
    # Plain text report, suitable for display in terminals.
    class PlainText < Report
      # Generates a string representation of the report
      def generate
        report = "== #{filename} ==\n".color(:yellow)
        report << entries.join("\n")
      end

      def display(stream = $stdout)
        stream.puts generate
      end
    end
  end
end
