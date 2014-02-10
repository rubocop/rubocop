# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of String#%.
      #
      # It cannot be implemented in a reliable manner for all cases, so
      # only two scenarios are considered - if the first argument is a string
      # literal and if the second argument is an array literal.
      class FormatString < Cop
        include ConfigurableEnforcedStyle

        def on_send(node)
          add_offence(node, :selector) if offending_node?(node)
        end

        private

        def offending_node?(node)
          case style
          when :format
            sprintf?(node) || percent?(node)
          when :sprintf
            format?(node) || percent?(node)
          when :percent
            format?(node) || sprintf?(node)
          end
        end

        def format?(node)
          command?(:format, node)
        end

        def sprintf?(node)
          command?(:sprintf, node)
        end

        def percent?(node)
          receiver_node, method_name, *arg_nodes = *node

          method_name == :% &&
            ([:str, :dstr].include?(receiver_node.type) ||
             arg_nodes[0].type == :array)
        end

        def message(node)
          _receiver_node, method_name, *_arg_nodes = *node

          preferred =
            if style == :percent
              'String#%'
            else
              style
            end

          method_name = 'String#%' if method_name == :%

          "Favor #{preferred} over #{method_name}."
        end
      end
    end
  end
end
