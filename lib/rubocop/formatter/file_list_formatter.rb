# encoding: utf-8

module Rubocop
  module Formatter
    # This formatter displays just a list of the files with offences in them,
    # separated by newlines.
    #
    # Here's the format:
    #
    # /some/file
    # /some/other/file
    class FileListFormatter < SimpleTextFormatter
      def report_file(file, offences)
        output.printf("%s\n", file)
      end
    end
  end
end
