# encoding: utf-8

module Rubocop
  module Formatter
    class BaseFormatter
      attr_reader :output

      def initialize(output)
        @output = output
      end

      def started(all_files)
      end

      def file_started(file, options)
      end

      def file_finished(file, offences)
      end

      def finished(processed_files)
      end
    end
  end
end
