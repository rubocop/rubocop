# encoding: utf-8

module Rubocop
  module Cop
    class BlockComments < Cop
      MSG = 'Do not use block comments.'

      def inspect(file, source, tokens, ast, comments)
        source.each_with_index do |line, ix|
          add_offence(:convention, ix, MSG) if line =~ /\A=begin\b/
        end
      end
    end
  end
end
