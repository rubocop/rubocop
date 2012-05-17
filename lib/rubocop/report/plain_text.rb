module Rubocop
  module Report
    # Plain text report, suitable for display in terminals.
    class PlainText
      attr_accessor :entries
      attr_accessor :filename

      # @param [String] the filename for this report
      def initialize(filename)
        @filename = filename
        @entries = []
      end

      # Appends offences registered by cops to the report.
      # @param [Cop] a cop with something to report
      def <<(cop)
        cop.offences.each do |entry|
          @entries << entry
        end
      end

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
