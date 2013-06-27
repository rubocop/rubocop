# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      class RescueModifier < Cop
        MSG = 'Avoid using rescue in its modifier form.'

        def on_kwbegin(node)
          body, *_ = *node
          return if normal_rescue?(body)
          super
        end

        def on_def(node)
          _method_name, _args, body = *node
          return if normal_rescue?(body)
          super
        end

        def on_defs(node)
          _receiver, _method_name, _args, body = *node
          return if normal_rescue?(body)
          super
        end

        def normal_rescue?(node)
          return false unless node

          case node.type
          when :rescue
            # Skip only the rescue node and continue processing its children.
            process_regular_node(node)
            true
          when :ensure
            first_child = node.children.first
            if first_child && first_child.type == :rescue
              process_regular_node(first_child)
              true
            else
              false
            end
          else
            false
          end
        end

        def on_rescue(node)
          add_offence(:convention, node.loc.expression, MSG)
        end
      end
    end
  end
end
