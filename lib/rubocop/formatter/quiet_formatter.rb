# encoding: utf-8

module RuboCop
  module Formatter
    # If no offences are found, no output is displayed.
    # Otherwise, SimpleTextFormatter's output is displayed.
    class QuietFormatter < SimpleTextFormatter
      def report_summary(file_count, offense_count, correction_count)
        super unless offense_count.zero?
      end
    end
  end
end
