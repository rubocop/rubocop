# encoding: utf-8

module Rubocop
  module Cop
    class LineContinuation < Cop
      MSG = 'Avoid the use of the line continuation character(\).'

      def inspect(source, tokens, ast, comments)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, MSG) if line =~ /.*\\\z/
        end
      end
    end
  end
end
