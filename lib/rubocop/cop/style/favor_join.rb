# encoding: utf-8

module Rubocop
  module Cop
    module Style
      class FavorJoin < Cop
        MSG = 'Favor Array#join over Array#*.'

        def on_send(node)
          receiver_node, method_name, *arg_nodes = *node

          if receiver_node && receiver_node.type == :array &&
              method_name == :* && arg_nodes[0].type == :str
            add_offence(:convention,
                        node.loc.selector,
                        MSG)
          end

          super
        end
      end
    end
  end
end
