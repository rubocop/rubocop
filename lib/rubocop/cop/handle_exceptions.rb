# encoding: utf-8

module Rubocop
  module Cop
    class HandleExceptions < Cop
      ERROR_MESSAGE = 'Do not suppress exceptions.'

      def self.portable?
        true
      end

      def inspect(file, source, sexp)
        on_node(:resbody, sexp) do |node|
          _exc_list_node, _exc_var_node, body_node = *node

          add_offence(:warning,
                      node.src.line,
                      ERROR_MESSAGE) if body_node.type == :nil
        end
      end
    end
  end
end
