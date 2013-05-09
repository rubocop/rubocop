# encoding: utf-8

module Rubocop
  module Cop
    class LineLength < Cop
      ERROR_MESSAGE = 'Line is too long. [%d/%d]'

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, index|
          max = LineLength.max
          if line.length > max
            message = sprintf(ERROR_MESSAGE, line.length, max)
            add_offence(:convention, index + 1, message)
          end
        end
      end

      def self.max
        LineLength.config['Max']
      end
    end
  end
end
