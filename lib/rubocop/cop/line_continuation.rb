# encoding: utf-8

module Rubocop
  module Cop
    class LineContinuation < Cop
      MSG = 'Avoid the use of the line continuation character(/).'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index, MSG) if line =~ /.*\\\z/
        end
      end
    end
  end
end
