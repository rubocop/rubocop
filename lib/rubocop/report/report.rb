module Rubocop
  module Report
    # Creates a Report object, based on the current settings
    #
    # @param [String] the filename for the report
    # @return [Report] a report object
    def create(file, output_mode = :default)
      case output_mode
      when :default     then PlainText.new(file)
      when :emacs_style then EmacsStyle.new(file)
      end
    end

    module_function :create

    class Report
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

      def empty?
        entries.empty?
      end
    end
  end
end
