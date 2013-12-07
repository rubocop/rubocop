# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      class RescueModifier < Cop
        include CheckMethods

        MSG = 'Avoid using rescue in its modifier form.'

        def on_rescue(node)
          return if ignored_node?(node)

          add_offence(node, :expression)
        end

        def on_kwbegin(node)
          body, *_ = *node
          check(nil, nil, nil, body)
        end

        def check(_node, _method_name, _args, body)
          return unless body

          case body.type
          when :rescue
            ignore_node(body)
          when :ensure
            first_child = body.children.first
            if first_child && first_child.type == :rescue
              ignore_node(first_child)
            end
          end
        end
      end
    end
  end
end
