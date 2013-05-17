# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLines < Cop
      ERROR_MESSAGE = 'Extra blank line detected.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        source.each_with_index do |line, ix|
          if ix > 0 && line.empty? && source[ix - 1].empty?
            add_offence(:convention, ix, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
