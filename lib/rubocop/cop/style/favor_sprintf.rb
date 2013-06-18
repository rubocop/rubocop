# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class FavorSprintf < Cop
        MSG = 'Favor sprintf over String#%.'

        def on_send(node)
          receiver_node, method_name, *arg_nodes = *node

          if method_name == :% &&
              ([:str, :dstr].include?(receiver_node.type) ||
               arg_nodes[0].type == :array)
            add_offence(:convention, node.loc.selector, MSG)
          end

          super
        end
      end
    end
  end
end
