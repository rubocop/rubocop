# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter displays just a list of the files with offenses in them,
    # separated by newlines. The output is machine-parsable.
    #
    # Here's the format:
    #
    # /some/file
    # /some/other/file
    class FileListFormatter < BaseFormatter
      def file_finished(file, offenses)
        return if offenses.empty?
        output.printf("%s\n", file)
      end
    end
  end
end
