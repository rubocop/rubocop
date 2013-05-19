# encoding: utf-8

module Rubocop
  module Cop
    class SymbolName < Cop
      MSG = 'Use snake_case for symbols.'
      SNAKE_CASE = /^[\da-z_]+[!?=]?$/
      CAMEL_CASE = /^[A-Z][A-Za-z\d]*$/

      def allow_camel_case?
        self.class.config['AllowCamelCase']
      end

      def inspect(file, source, tokens, ast)
        on_node(:sym, ast) do |node|
          sym_name = node.to_a[0]
          next unless sym_name =~ /^[a-zA-Z]/
          next if sym_name =~ SNAKE_CASE
          next if allow_camel_case? && sym_name =~ CAMEL_CASE
          add_offence(:convention,
                      node.src.line,
                      MSG)
        end
      end
    end
  end
end
