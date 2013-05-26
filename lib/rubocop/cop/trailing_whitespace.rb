# encoding: utf-8

module Rubocop
  module Cop
    class TrailingWhitespace < Cop
      MSG = 'Trailing whitespace detected.'

      def inspect(file, source, tokens, ast, comments)
        source.each_with_index do |line, index|
          add_offence(:convention, index + 1, MSG) if line =~ /.*[ \t]+$/
        end
      end
    end
  end
end
