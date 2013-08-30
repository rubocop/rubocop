# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      class RescueModifier < Cop
        MSG = 'Avoid using rescue in its modifier form.'

        def on_rescue(node)
          return if ignored_node?(node)

          convention(node, :expression)
        end

        def on_kwbegin(node)
          body, *_ = *node
          check_rescue(body)
        end

        def on_def(node)
          _method_name, _args, body = *node
          check_rescue(body)
        end

        def on_defs(node)
          _receiver, _method_name, _args, body = *node
          check_rescue(body)
        end

        def check_rescue(node)
          return unless node

          case node.type
          when :rescue
            ignore_node(node)
          when :ensure
            first_child = node.children.first
            if first_child && first_child.type == :rescue
              ignore_node(first_child)
            end
          end
        end
      end
    end
  end
end
