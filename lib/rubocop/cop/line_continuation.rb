# encoding: utf-8

module Rubocop
  module Cop
    class LineContinuation < Cop
      MSG = 'Avoid the use of the line continuation character(\).'

      def inspect(source, tokens, ast, comments)
        source.each_with_index do |line, index|
          if line =~ /.*\\\z/
            add_offence(:convention, Location.new(index + 1, line.length), MSG)
          end
        end
      end
    end
  end
end
