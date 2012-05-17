module Rubocop
  module Report
    # Plain text report, suitable for display in terminals.
    class PlainText < Report
      # Generates a string representation of the report
      def generate
        report = "== #{filename} ==\n"
        report << entries.join("\n")
      end

      def display
        puts generate
      end
    end
  end
end
