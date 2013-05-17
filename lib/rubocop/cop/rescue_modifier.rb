# encoding: utf-8

module Rubocop
  module Cop
    class RescueModifier < Cop
      ERROR_MESSAGE = 'Avoid using rescue in its modifier form.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:rescue, sexp, :begin) do |s|
          add_offence(:convention,
                      s.src.line,
                      ERROR_MESSAGE)
        end
      end
    end
  end
end
