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

      def on_sym(node)
        sym_name = node.to_a[0]
        return unless sym_name =~ /^[a-zA-Z]/
        return if sym_name =~ SNAKE_CASE
        return if allow_camel_case? && sym_name =~ CAMEL_CASE
        add_offence(:convention, node.loc, MSG)
      end
    end
  end
end
