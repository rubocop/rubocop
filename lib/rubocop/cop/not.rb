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
          _, method_name = *s

          if method_name == :! && s.src.selector.to_source == 'not'
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
