# encoding: utf-8
# frozen_string_literal: false

module RuboCop
  module Formatter
    # This formatter displays the report data in format that's
    # easy to process in the Emacs text editor.
    # The output is machine-parsable.
    class EmacsStyleFormatter < BaseFormatter
      def file_finished(file, offenses)
        offenses.each do |o|
          message = o.corrected? ? '[Corrected] ' : ''
          message << o.message

          output.printf("%s:%d:%d: %s: %s\n",
                        file, o.line, o.real_column, o.severity.code,
                        message.tr("\n", ' '))
        end
      end
    end
  end
end
