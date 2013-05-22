# encoding: utf-8

module Rubocop
  module Cop
    class ClassMethods < Cop
      MSG = 'Prefer self over class/module for class/module methods.'

      def on_defs(node)
        definee, _name, _args, _body = *node

        add_offence(:convention, node.src.line, MSG) if definee.type == :const
      end
    end
  end
end
