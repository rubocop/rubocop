# encoding: utf-8

module Rubocop
  module Cop
    class Tab < Cop
      MSG = 'Tab detected.'

      def inspect(source_buffer, source, tokens, ast, comments)
        source.each_with_index do |line, index|
          if line =~ /^ *\t/
            add_offence(:convention, Location.new(index + 1, 0, source), MSG)
          end
        end
      end
    end
  end
end
