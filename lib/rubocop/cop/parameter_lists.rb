# encoding: utf-8

module Rubocop
  module Cop
    class ParameterLists < Cop
      MSG = 'Avoid parameter lists longer than four parameters.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:args, sexp) do |s|
          if s.children.size > 4
            add_offence(:convention, s.src.line, MSG)
          end
        end
      end
    end
  end
end
