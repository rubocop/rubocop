# encoding: utf-8

module Rubocop
  module Cop
    class Eval < Cop
      MSG = 'The use of eval is a serious security risk.'

      def on_send(node)
        receiver, method_name, = *node

        if receiver.nil? && method_name == :eval
          add_offence(:security, node.loc.line, MSG)
        end

        super
      end
    end
  end
end
