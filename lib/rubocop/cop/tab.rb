# encoding: utf-8

module Rubocop
  module Cop
    class Tab < Cop
      MSG = 'Tab detected.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, MSG) if line =~ /^ *\t/
        end
      end
    end
  end
end
