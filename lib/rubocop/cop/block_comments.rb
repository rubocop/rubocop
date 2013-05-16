# encoding: utf-8

module Rubocop
  module Cop
    class BlockComments < Cop
      ERROR_MESSAGE = 'Do not use block comments.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, ix|
          add_offence(:convention, ix, ERROR_MESSAGE) if line =~ /\A=begin\b/
        end
      end
    end
  end
end
