# encoding: utf-8

module Rubocop
  module Cop
    class LineLength < Cop
      MSG = 'Line is too long. [%d/%d]'

      def inspect(file, source, tokens, ast, comments)
        source.each_with_index do |line, index|
          max = LineLength.max
          if line.length > max
            message = sprintf(MSG, line.length, max)
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
