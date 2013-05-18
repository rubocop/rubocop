# encoding: utf-8

module Rubocop
  module Cop
    class FavorSprintf < Cop
      MSG = 'Favor sprintf over String#%.'

      def inspect(file, source, tokens, sexp)
        on_node(:send, sexp) do |s|
          receiver_node, method_name, *arg_nodes = *s

          if method_name == :% &&
              ([:str, :dstr].include?(receiver_node.type) ||
               arg_nodes[0].type == :array)
            add_offence(:convention, s.src.expression.line, MSG)
          end
        end
      end
    end
  end
end
