# frozen_string_literal: true

module RuboCop
  module Formatter
    # This formatter displays the report data in format that's
    # easy to process in the Emacs text editor.
    # The output is machine-parsable.
    class EmacsStyleFormatter < BaseFormatter
      def file_finished(file, offenses)
        offenses.each do |o|
          message = if o.corrected?
                      "[Corrected] #{o.message}"
                    else
                      o.message
                    end

          output.printf("%s:%d:%d: %s: %s\n",
                        file, o.line, o.real_column, o.severity.code,
                        message.tr("\n", ' '))
        end
      end
    end
  end
end
