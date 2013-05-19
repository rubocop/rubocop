# encoding: utf-8

module Rubocop
  module Cop
    class HandleExceptions < Cop
      MSG = 'Do not suppress exceptions.'

      def inspect(file, source, tokens, ast)
        on_node(:resbody, ast) do |node|
          _exc_list_node, _exc_var_node, body_node = *node

          add_offence(:warning,
                      node.src.line,
                      MSG) if body_node.type == :nil
        end
      end
    end
  end
end
