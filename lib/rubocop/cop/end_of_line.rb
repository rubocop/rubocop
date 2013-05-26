# encoding: utf-8

module Rubocop
  module Cop
    class EndOfLine < Cop
      MSG = 'Carriage return character detected.'

      def inspect(source, tokens, ast, comments)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, MSG) if line =~ /\r$/
        end
      end
    end
  end
end
