# encoding: utf-8

module Rubocop
  module Cop
    class FavorSprintf < Cop
      ERROR_MESSAGE = 'Favor sprintf over String#%.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:send, sexp) do |s|
          receiver_node, method_name, *arg_nodes = *s

          if method_name == :% &&
              ([:str, :dstr].include?(receiver_node.type) ||
               arg_nodes[0].type == :array)
            add_offence(:convention, s.src.expression.line, ERROR_MESSAGE)
          end
        end
      end
    end
  end
end
