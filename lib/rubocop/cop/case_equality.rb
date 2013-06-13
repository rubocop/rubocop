# encoding: utf-8

module Rubocop
  module Cop
    class CaseEquality < Cop
      MSG = 'Avoid the use of the case equality operator(===).'

      def on_send(node)
        _receiver, method_name, *_args = *node

        if method_name == :===
            add_offence(:convention, node.loc.expression, MSG)
        end

        super
      end
    end
  end
end
