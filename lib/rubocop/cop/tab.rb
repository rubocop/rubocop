# encoding: utf-8

module Rubocop
  module Cop
    class Tab < Cop
      MSG = 'Tab detected.'

      def inspect(file, source, tokens, ast)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, MSG) if line =~ /^ *\t/
        end
      end
    end
  end
end
