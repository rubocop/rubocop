# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of "*" as a substitute for *join*.
      #
      # Not all cases can reliably checked, due to Ruby's dynamic
      # types, so we consider only cases when the first argument is an
      # array literal or the second is a string literal.
      class FavorJoin < Cop
        MSG = 'Favor Array#join over Array#*.'

        def on_send(node)
          receiver_node, method_name, *arg_nodes = *node

          if receiver_node && receiver_node.type == :array &&
              method_name == :* && arg_nodes[0].type == :str
            add_offence(node, :selector)
          end
        end
      end
    end
  end
end
