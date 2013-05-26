# encoding: utf-8

module Rubocop
  module Cop
    class ColonMethodCall < Cop
      MSG = 'Do not use :: for method invocation.'

      def on_send(node)
        receiver, _method_name, *_args = *node

        # discard methods with nil receivers and op methods(like [])
        if receiver && node.loc.dot && node.loc.dot.source == '::'
          add_offence(:convention, node.loc.line, MSG)
        end

        super
      end
    end
  end
end
