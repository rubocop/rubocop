module Rubocop
  module Cop
    class EmptyLines < Cop
      ERROR_MESSAGE = 'Use empty lines between defs.'

      def inspect(file, source, tokens, sexp)
        empty_line_detected = false
        source.each_with_index do |line, index|
          case line
          when /^[\t ]*$/
            empty_line_detected = true
          when /^[\t ]*def\b/
            unless empty_line_detected
              add_offence(:convention, index, line, ERROR_MESSAGE)
            end
            empty_line_detected = false
          when /^[\t ]*#/
            nil  # pay no attention to comment lines
          else
            empty_line_detected = false
          end
        end
      end
    end
  end
end
