# encoding: utf-8

module Rubocop
  module Cop
    class EndOfLine < Cop
      ERROR_MESSAGE = 'Carriage return character detected.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, ERROR_MESSAGE) if line =~ /\r$/
        end
      end
    end
  end
end
