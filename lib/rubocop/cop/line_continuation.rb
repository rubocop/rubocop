# encoding: utf-8

module Rubocop
  module Cop
    class LineContinuation < Cop
      MSG = 'Avoid the use of the line continuation character(/).'

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, index|
          add_offence(:convention, index, MSG) if line =~ /.*\\\z/
        end
      end
    end
  end
end
