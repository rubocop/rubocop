# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      class RescueModifier < Cop
        MSG = 'Avoid using rescue in its modifier form.'

        def on_def(node)
          _method_name, _args, body = *node
          # Skip processing child nodes
          # if this method has rescue with implicit begin.
          return if body && body.type == :rescue
          super
        end

        def on_defs(node)
          _receiver, _method_name, _args, body = *node
          return if body && body.type == :rescue
          super
        end

        def on_rescue(node)
          add_offence(:convention, node.loc.expression, MSG)
        end

        alias_method :on_kwbegin, :ignore_node
      end
    end
  end
end
