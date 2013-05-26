# encoding: utf-8

module Rubocop
  module Cop
    class Tab < Cop
      MSG = 'Tab detected.'

      def inspect(source, tokens, ast, comments)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, MSG) if line =~ /^ *\t/
        end
      end
    end
  end
end
