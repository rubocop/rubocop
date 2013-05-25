# encoding: utf-8

module Rubocop
  module Cop
    class ParameterLists < Cop
      MSG = 'Avoid parameter lists longer than four parameters.'

      def on_args(node)
        args_count = node.children.size

        add_offence(:convention, node.loc.line, MSG) if args_count > 4

        super
      end
    end
  end
end
