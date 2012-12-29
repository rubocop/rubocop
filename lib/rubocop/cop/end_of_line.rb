# encoding: utf-8

module Rubocop
  module Cop
    class EndOfLine < Cop
      ERROR_MESSAGE = 'Carriage return character detected.'

      def inspect(file, source)
        source.each_with_index do |line, index|
          if line =~ /\r$/
            add_offence(:convention, index, line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
