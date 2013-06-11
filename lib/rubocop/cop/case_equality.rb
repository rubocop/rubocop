# encoding: utf-8

module Rubocop
  module Cop
    class CaseEquality < Cop
      MSG = 'Avoid the use of the case equality operator(===).'

      def on_send(node)
        _receiver, method_name, *_args = *node

        add_offence(:convention, node.loc, MSG) if method_name == :===

        super
      end
    end
  end
end
