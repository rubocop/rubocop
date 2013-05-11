# encoding: utf-8

module Rubocop
  module Cop
    class SymbolSnakeCase < Cop
      ERROR_MESSAGE = 'Use snake_case for symbols.'
      SNAKE_CASE = /^[\da-z_]+[!?=]?$/

      def self.portable?
        true
      end

      def inspect(file, source, tokens, sexp)
        on_node(:sym, sexp) do |s|
          sym_name = s.to_a[0]
          next unless sym_name =~ /^[a-zA-Z]/

          unless sym_name =~ SNAKE_CASE
            line_no = s.src.line
            add_offence(:convention,
                        line_no,
                        ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
