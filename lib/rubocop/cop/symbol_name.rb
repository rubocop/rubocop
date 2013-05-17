# encoding: utf-8

module Rubocop
  module Cop
    class SymbolName < Cop
      ERROR_MESSAGE = 'Use snake_case for symbols.'
      SNAKE_CASE = /^[\da-z_]+[!?=]?$/
      CAMEL_CASE = /^[A-Z][A-Za-z\d]*$/

      def self.portable?
        true
      end

      def allow_camel_case?
        self.class.config['AllowCamelCase']
      end

      def inspect(file, source, sexp)
        on_node(:sym, sexp) do |s|
          sym_name = s.to_a[0]
          next unless sym_name =~ /^[a-zA-Z]/
          next if sym_name =~ SNAKE_CASE
          next if allow_camel_case? && sym_name =~ CAMEL_CASE
          add_offence(:convention,
                      s.source_map.line,
                      ERROR_MESSAGE)
        end
      end
    end
  end
end
