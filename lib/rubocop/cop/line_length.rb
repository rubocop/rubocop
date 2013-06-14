# encoding: utf-8

module Rubocop
  module Cop
    class LineLength < Cop
      MSG = 'Line is too long. [%d/%d]'

      def inspect(source_buffer, source, tokens, ast, comments)
        source.each_with_index do |line, index|
          max = LineLength.max
          if line.length > max
            message = sprintf(MSG, line.length, max)
            add_offence(:convention,
                        Location.new(index + 1, LineLength.max, source),
                        message)
          end
        end
      end

      def self.max
        LineLength.config['Max']
      end
    end
  end
end
