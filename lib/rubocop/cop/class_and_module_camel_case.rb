# encoding: utf-8

module Rubocop
  module Cop
    class ClassAndModuleCamelCase < Cop
      MSG = 'Use CamelCase for classes and modules.'

      def on_class(node)
        check_name(node)

        super
      end

      def on_module(node)
        check_name(node)

        super
      end

      private

      def check_name(node)
        name = node.src.name.to_source

        add_offence(:convention, node.src.line, MSG) if name =~ /_/
      end
    end
  end
end
