# encoding: utf-8

module Rubocop
  module Cop
    class ParameterLists < Cop
      ERROR_MESSAGE = 'Avoid parameter lists longer than four parameters.'

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:args, sexp) do |s|
          if s.children.size > 4
            add_offence(:convention, s.src.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
