# encoding: utf-8

module Rubocop
  module Cop
    class RescueModifier < Cop
      MSG = 'Avoid using rescue in its modifier form.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:rescue, sexp, :begin) do |s|
          add_offence(:convention,
                      s.src.line,
                      MSG)
        end
      end
    end
  end
end
