# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of String#%.
      #
      # It cannot be implemented in a reliable manner for all cases, so
      # only two scenarios are considered - if the first argument is a string
      # literal and if the second argument is an array literal.
      class FavorSprintf < Cop
        MSG = 'Favor sprintf over String#%.'

        def on_send(node)
          receiver_node, method_name, *arg_nodes = *node

          if method_name == :% &&
              ([:str, :dstr].include?(receiver_node.type) ||
               arg_nodes[0].type == :array)
            add_offence(node, :selector)
          end
        end
      end
    end
  end
end
