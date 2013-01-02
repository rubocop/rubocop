# encoding: utf-8

module Rubocop
  module Cop
    class LineLength < Cop
      ERROR_MESSAGE = 'Line is too long. [%d/%d]'
      MAX_LINE_LENGTH = 79

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, index|
          if line.length > MAX_LINE_LENGTH
            message = sprintf(ERROR_MESSAGE, line.length, MAX_LINE_LENGTH)
            add_offence(:convention, index + 1, message)
          end
        end
      end
    end
  end
end
