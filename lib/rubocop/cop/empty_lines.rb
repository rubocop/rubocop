# encoding: utf-8

module Rubocop
  module Cop
    class EmptyLines < Cop
      MSG = 'Extra blank line detected.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        source.each_with_index do |line, ix|
          if ix > 0 && line.empty? && source[ix - 1].empty?
            add_offence(:convention, ix, MSG)
          end
        end
      end
    end
  end
end
