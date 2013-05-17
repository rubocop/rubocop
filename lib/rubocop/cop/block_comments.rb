# encoding: utf-8

module Rubocop
  module Cop
    class BlockComments < Cop
      MSG = 'Do not use block comments.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        source.each_with_index do |line, ix|
          add_offence(:convention, ix, MSG) if line =~ /\A=begin\b/
        end
      end
    end
  end
end
