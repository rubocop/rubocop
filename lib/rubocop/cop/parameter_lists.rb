# encoding: utf-8

module Rubocop
  module Cop
    class ParameterLists < Cop
      MSG = 'Avoid parameter lists longer than four parameters.'

      def inspect(file, source, tokens, ast)
        on_node(:args, ast) do |node|
          args_count = node.children.size

          add_offence(:convention, node.src.line, MSG) if args_count > 4
        end
      end
    end
  end
end
