# encoding: utf-8

module Rubocop
  module Cop
    class Not < Cop
      ERROR_MESSAGE = 'Use ! instead of not.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |s|
          if s.to_a[1] == :! && s.src.selector.to_source == 'not'
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
